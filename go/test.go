package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"sync"
	"time"
)

// --- Types ---

type Status int

const (
	StatusPending Status = iota
	StatusActive
	StatusClosed
)

func (s Status) String() string {
	switch s {
	case StatusPending:
		return "pending"
	case StatusActive:
		return "active"
	case StatusClosed:
		return "closed"
	default:
		return "unknown"
	}
}

type User struct {
	ID        int       `json:"id"`
	Name      string    `json:"name"`
	Email     string    `json:"email"`
	Status    Status    `json:"status"`
	CreatedAt time.Time `json:"created_at"`
}

// --- Repository ---

type UserRepository struct {
	mu    sync.RWMutex
	store map[int]*User
	next  int
}

func NewUserRepository() *UserRepository {
	return &UserRepository{store: make(map[int]*User)}
}

var ErrNotFound = errors.New("not found")

func (r *UserRepository) Create(name, email string) *User {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.next++
	u := &User{
		ID:        r.next,
		Name:      name,
		Email:     email,
		Status:    StatusPending,
		CreatedAt: time.Now().UTC(),
	}
	r.store[u.ID] = u
	return u
}

func (r *UserRepository) FindByID(id int) (*User, error) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	if u, ok := r.store[id]; ok {
		return u, nil
	}
	return nil, fmt.Errorf("user %d: %w", id, ErrNotFound)
}

func (r *UserRepository) List() []*User {
	r.mu.RLock()
	defer r.mu.RUnlock()
	users := make([]*User, 0, len(r.store))
	for _, u := range r.store {
		users = append(users, u)
	}
	return users
}

// --- HTTP Handler ---

type UserHandler struct {
	repo *UserRepository
	log  *slog.Logger
}

func (h *UserHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		h.list(w, r)
	case http.MethodPost:
		h.create(w, r)
	default:
		http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
	}
}

func (h *UserHandler) list(w http.ResponseWriter, r *http.Request) {
	users := h.repo.List()
	respond(w, http.StatusOK, users)
}

func (h *UserHandler) create(w http.ResponseWriter, r *http.Request) {
	var body struct {
		Name  string `json:"name"`
		Email string `json:"email"`
	}
	if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
		http.Error(w, "bad request", http.StatusBadRequest)
		return
	}
	u := h.repo.Create(body.Name, body.Email)
	respond(w, http.StatusCreated, u)
}

func respond(w http.ResponseWriter, code int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(code)
	json.NewEncoder(w).Encode(v)
}

// --- Concurrency example ---

func fanOut(ctx context.Context, ids []int, repo *UserRepository) ([]*User, []error) {
	type result struct {
		user *User
		err  error
	}
	ch := make(chan result, len(ids))

	for _, id := range ids {
		go func(id int) {
			u, err := repo.FindByID(id)
			ch <- result{u, err}
		}(id)
	}

	var users []*User
	var errs []error
	for range ids {
		select {
		case <-ctx.Done():
			errs = append(errs, ctx.Err())
			return users, errs
		case r := <-ch:
			if r.err != nil {
				errs = append(errs, r.err)
			} else {
				users = append(users, r.user)
			}
		}
	}
	return users, errs
}

// --- Entry point ---

func main() {
	logger := slog.Default()
	repo := NewUserRepository()

	repo.Create("Alice", "alice@example.com")
	repo.Create("Bob", "bob@example.com")

	handler := &UserHandler{repo: repo, log: logger}

	mux := http.NewServeMux()
	mux.Handle("/users", handler)

	srv := &http.Server{
		Addr:         ":8081",
		Handler:      mux,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
	}

	logger.Info("listening", "addr", srv.Addr)
	if err := srv.ListenAndServe(); err != nil {
		logger.Error("server error", "err", err)
	}
}
