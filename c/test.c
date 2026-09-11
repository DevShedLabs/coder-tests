#include <assert.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ARRAY_LEN(items) (sizeof(items) / sizeof((items)[0]))
#define MAX_NAME 32

typedef enum {
    TASK_PENDING,
    TASK_RUNNING,
    TASK_DONE
} TaskStatus;

typedef struct {
    unsigned id;
    char name[MAX_NAME];
    TaskStatus status;
} Task;

typedef struct {
    Task *items;
    size_t length;
    size_t capacity;
} TaskList;

typedef int (*TaskPredicate)(const Task *task);

static const char *status_name(TaskStatus status) {
    switch (status) {
    case TASK_PENDING:
        return "pending";
    case TASK_RUNNING:
        return "running";
    case TASK_DONE:
        return "done";
    }
    return "unknown";
}

static bool list_init(TaskList *list, size_t capacity) {
    list->items = calloc(capacity, sizeof(*list->items));
    list->length = 0;
    list->capacity = list->items != NULL ? capacity : 0;
    return list->items != NULL;
}

static void list_destroy(TaskList *list) {
    free(list->items);
    *list = (TaskList){0};
}

static bool list_add(TaskList *list, unsigned id, const char *name, TaskStatus status) {
    if (list->length == list->capacity) {
        size_t new_capacity = list->capacity == 0 ? 4 : list->capacity * 2;
        Task *grown = realloc(list->items, new_capacity * sizeof(*grown));
        if (grown == NULL) {
            return false;
        }
        list->items = grown;
        list->capacity = new_capacity;
    }

    Task *task = &list->items[list->length++];
    task->id = id;
    task->status = status;
    snprintf(task->name, sizeof(task->name), "%s", name);
    return true;
}

static int is_open(const Task *task) {
    return task->status != TASK_DONE;
}

static size_t count_matching(const TaskList *list, TaskPredicate predicate) {
    size_t count = 0;
    for (size_t i = 0; i < list->length; i++) {
        if (predicate(&list->items[i])) {
            count++;
        }
    }
    return count;
}

static void print_task(const Task *task) {
    printf("[%u] %-12s %s\n", task->id, task->name, status_name(task->status));
}

int main(void) {
    const int priorities[] = {3, 1, 2, 5};
    TaskList list;

    assert(list_init(&list, 2));
    assert(list_add(&list, 101, "parse input", TASK_DONE));
    assert(list_add(&list, 102, "compile", TASK_RUNNING));
    assert(list_add(&list, 103, "run tests", TASK_PENDING));

    for (size_t i = 0; i < list.length; i++) {
        print_task(&list.items[i]);
    }

    printf("open tasks: %zu\n", count_matching(&list, is_open));
    printf("priority total: %d\n", priorities[0] + priorities[1] + priorities[2] + priorities[3]);

    char buffer[64] = "C editor test";
    char *suffix = strchr(buffer, ' ');
    if (suffix != NULL) {
        printf("first word length: %td\n", suffix - buffer);
    }
    assert(strcmp(status_name(TASK_RUNNING), "running") == 0);
    list_destroy(&list);
    return EXIT_SUCCESS;
}
