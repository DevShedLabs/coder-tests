use std::collections::HashMap;
use std::fmt;
use std::sync::{Arc, Mutex};

// --- Traits ---

trait Repository<T, ID> {
    fn find_by_id(&self, id: ID) -> Option<&T>;
    fn find_all(&self) -> Vec<&T>;
    fn save(&mut self, entity: T) -> &T;
    fn delete(&mut self, id: ID) -> bool;
}

// --- Types ---

#[derive(Debug, Clone, PartialEq)]
pub enum Role {
    Admin,
    Editor,
    Viewer,
}

impl fmt::Display for Role {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Role::Admin  => write!(f, "admin"),
            Role::Editor => write!(f, "editor"),
            Role::Viewer => write!(f, "viewer"),
        }
    }
}

#[derive(Debug, Clone)]
pub struct User {
    pub id: u32,
    pub name: String,
    pub email: String,
    pub role: Role,
}

impl User {
    pub fn new(id: u32, name: impl Into<String>, email: impl Into<String>, role: Role) -> Self {
        Self { id, name: name.into(), email: email.into(), role }
    }

    pub fn is_admin(&self) -> bool {
        self.role == Role::Admin
    }
}

impl fmt::Display for User {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}#{} <{}> [{}]", self.name, self.id, self.email, self.role)
    }
}

// --- In-memory repository ---

pub struct UserRepo {
    store:   HashMap<u32, User>,
    counter: u32,
}

impl UserRepo {
    pub fn new() -> Self {
        Self { store: HashMap::new(), counter: 0 }
    }
}

impl Repository<User, u32> for UserRepo {
    fn find_by_id(&self, id: u32) -> Option<&User> {
        self.store.get(&id)
    }

    fn find_all(&self) -> Vec<&User> {
        self.store.values().collect()
    }

    fn save(&mut self, mut entity: User) -> &User {
        if entity.id == 0 {
            self.counter += 1;
            entity.id = self.counter;
        }
        self.store.insert(entity.id, entity);
        self.store.get(&self.counter).unwrap()
    }

    fn delete(&mut self, id: u32) -> bool {
        self.store.remove(&id).is_some()
    }
}

// --- Generic result wrapper ---

#[derive(Debug)]
pub enum AppError {
    NotFound(String),
    Validation(String),
    Internal(String),
}

impl fmt::Display for AppError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            AppError::NotFound(msg)   => write!(f, "Not found: {msg}"),
            AppError::Validation(msg) => write!(f, "Validation: {msg}"),
            AppError::Internal(msg)   => write!(f, "Internal: {msg}"),
        }
    }
}

type Result<T> = std::result::Result<T, AppError>;

// --- Service layer ---

pub struct UserService {
    repo: Arc<Mutex<UserRepo>>,
}

impl UserService {
    pub fn new(repo: Arc<Mutex<UserRepo>>) -> Self {
        Self { repo }
    }

    pub fn create(&self, name: &str, email: &str, role: Role) -> Result<u32> {
        if name.trim().is_empty() {
            return Err(AppError::Validation("name cannot be empty".into()));
        }
        if !email.contains('@') {
            return Err(AppError::Validation(format!("invalid email: {email}")));
        }
        let user = User::new(0, name, email, role);
        let mut repo = self.repo.lock().unwrap();
        let saved = repo.save(user);
        Ok(saved.id)
    }

    pub fn get(&self, id: u32) -> Result<User> {
        let repo = self.repo.lock().unwrap();
        repo.find_by_id(id)
            .cloned()
            .ok_or_else(|| AppError::NotFound(format!("user {id}")))
    }

    pub fn admins(&self) -> Vec<User> {
        let repo = self.repo.lock().unwrap();
        repo.find_all()
            .into_iter()
            .filter(|u| u.is_admin())
            .cloned()
            .collect()
    }
}

// --- Iterators & closures ---

fn top_names(users: &[User], limit: usize) -> Vec<&str> {
    let mut names: Vec<&str> = users.iter().map(|u| u.name.as_str()).collect();
    names.sort_unstable();
    names.truncate(limit);
    names
}

// --- Entry point ---

fn main() {
    let repo = Arc::new(Mutex::new(UserRepo::new()));
    let svc  = UserService::new(Arc::clone(&repo));

    let ids: Vec<u32> = [
        ("Alice", "alice@example.com", Role::Admin),
        ("Bob",   "bob@example.com",   Role::Editor),
        ("Carol", "carol@example.com", Role::Viewer),
    ]
    .iter()
    .filter_map(|(name, email, role)| svc.create(name, email, role.clone()).ok())
    .collect();

    for id in &ids {
        match svc.get(*id) {
            Ok(user) => println!("{user}"),
            Err(e)   => eprintln!("error: {e}"),
        }
    }

    let admins = svc.admins();
    println!("\nAdmins ({}):", admins.len());
    for a in &admins {
        println!("  {a}");
    }

    // Pattern matching with if-let chains
    if let Ok(user) = svc.get(1) {
        if user.is_admin() {
            println!("\n{} has elevated privileges", user.name);
        }
    }

    // Error handling
    match svc.create("", "bad", Role::Viewer) {
        Ok(_)  => unreachable!(),
        Err(e) => println!("\nExpected error: {e}"),
    }
}
