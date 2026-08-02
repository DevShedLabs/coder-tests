<?php

declare(strict_types=1);

namespace App\Models;

use App\Contracts\Cacheable;
use App\Exceptions\NotFoundException;
use DateTime;
use JsonSerializable;

/**
 * User model representing an authenticated account.
 */
class User implements JsonSerializable, Cacheable
{
    private static array $instances = [];

    public function __construct(
        private readonly int $id,
        private string $name,
        private string $email,
        private ?DateTime $verifiedAt = null,
        private array $roles = [],
    ) {}

    public static function find(int $id): static
    {
        if (isset(static::$instances[$id])) {
            return static::$instances[$id];
        }

        $row = db()->selectOne('SELECT * FROM users WHERE id = ?', [$id]);

        if (!$row) {
            throw new NotFoundException("User {$id} not found");
        }

        return static::$instances[$id] = new static(
            id: $row['id'],
            name: $row['name'],
            email: $row['email'],
            verifiedAt: $row['verified_at'] ? new DateTime($row['verified_at']) : null,
            roles: json_decode($row['roles'], true) ?? [],
        );
    }

    public function isVerified(): bool
    {
        return $this->verifiedAt !== null;
    }

    public function hasRole(string $role): bool
    {
        return in_array($role, $this->roles, strict: true);
    }

    public function getCacheKey(): string
    {
        return "user:{$this->id}";
    }

    public function jsonSerialize(): array
    {
        return [
            'id'          => $this->id,
            'name'        => $this->name,
            'email'       => $this->email,
            'verified'    => $this->isVerified(),
            'roles'       => $this->roles,
            'verified_at' => $this->verifiedAt?->format(DateTime::ATOM),
        ];
    }

    // Getters
    public function getId(): int    { return $this->id; }
    public function getName(): string { return $this->name; }
    public function getEmail(): string { return $this->email; }

    public function setName(string $name): static
    {
        $this->name = trim($name);
        return $this;
    }
}

// --- Standalone helpers ---

function paginate(array $items, int $perPage = 15, int $page = 1): array
{
    $offset = ($page - 1) * $perPage;
    $slice  = array_slice($items, $offset, $perPage);

    return [
        'data'         => $slice,
        'total'        => count($items),
        'per_page'     => $perPage,
        'current_page' => $page,
        'last_page'    => (int) ceil(count($items) / $perPage),
    ];
}

// Match expression (PHP 8+)
function statusLabel(int $code): string
{
    return match(true) {
        $code >= 500 => 'Server Error',
        $code >= 400 => 'Client Error',
        $code >= 300 => 'Redirect',
        $code >= 200 => 'Success',
        default      => 'Unknown',
    };
}

// Fibers (PHP 8.1+)
$fiber = new \Fiber(function (): string {
    $value = \Fiber::suspend('first suspension');
    echo "Resumed with: {$value}\n";
    return 'fiber complete';
});

$result = $fiber->start();
echo $result . PHP_EOL;
$fiber->resume('hello');
