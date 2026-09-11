#include <algorithm>
#include <cassert>
#include <concepts>
#include <functional>
#include <iostream>
#include <memory>
#include <optional>
#include <ranges>
#include <string>
#include <string_view>
#include <variant>
#include <vector>

enum class Status { pending, running, complete };

struct Task {
    int id;
    std::string title;
    Status status;

    [[nodiscard]] bool is_open() const { return status != Status::complete; }
};

class TaskBoard {
public:
    void add(Task task) { tasks_.push_back(std::move(task)); }

    [[nodiscard]] const std::vector<Task> &tasks() const noexcept { return tasks_; }

    template <typename Predicate>
        requires std::predicate<Predicate, const Task &>
    [[nodiscard]] std::vector<std::reference_wrapper<const Task>> where(Predicate predicate) const {
        std::vector<std::reference_wrapper<const Task>> matches;
        for (const Task &task : tasks_) {
            if (std::invoke(predicate, task)) {
                matches.emplace_back(task);
            }
        }
        return matches;
    }

private:
    std::vector<Task> tasks_;
};

struct Created {
    int id;
};
struct Rejected {
    std::string reason;
};
using Result = std::variant<Created, Rejected>;

[[nodiscard]] Result create_task(std::string_view title) {
    if (title.empty()) {
        return Rejected{"title cannot be empty"};
    }
    return Created{42};
}

[[nodiscard]] std::string status_name(Status status) {
    switch (status) {
    case Status::pending:
        return "pending";
    case Status::running:
        return "running";
    case Status::complete:
        return "complete";
    }
    return "unknown";
}

int main() {
    TaskBoard board;
    board.add({1, "parse input", Status::complete});
    board.add({2, "compile project", Status::running});
    board.add({3, "run tests", Status::pending});

    const auto open_tasks = board.where(&Task::is_open);
    for (const Task &task : board.tasks() | std::views::filter(&Task::is_open)) {
        std::cout << task.id << ": " << task.title << " (" << status_name(task.status) << ")\n";
    }

    std::vector<int> ids;
    std::ranges::transform(open_tasks, std::back_inserter(ids),
                           [](const std::reference_wrapper<const Task> &task) { return task.get().id; });
    assert(ids.size() == 2);
    assert(std::holds_alternative<Created>(create_task("new task")));
    assert(std::holds_alternative<Rejected>(create_task("")));

    auto optional_task = std::make_optional(Task{4, "optional", Status::pending});
    std::unique_ptr<Task> owned_task = std::make_unique<Task>(std::move(*optional_task));
    std::cout << "owned: " << owned_task->title << "\n";
    return 0;
}
