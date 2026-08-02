// TypeScript feature coverage: generics, decorators, discriminated unions,
// async/await, utility types, mapped types, template literal types.

// --- Utility types & generics ---

type Nullable<T> = T | null
type AsyncResult<T> = Promise<{ data: T; error: null } | { data: null; error: Error }>

async function tryCatch<T>(fn: () => Promise<T>): AsyncResult<T> {
  try {
    return { data: await fn(), error: null }
  } catch (e) {
    return { data: null, error: e instanceof Error ? e : new Error(String(e)) }
  }
}

// --- Discriminated union ---

type ApiResponse<T> =
  | { status: 'ok';      data: T }
  | { status: 'error';   message: string; code: number }
  | { status: 'loading' }

function handleResponse<T>(res: ApiResponse<T>): T | null {
  switch (res.status) {
    case 'ok':      return res.data
    case 'error':   throw new Error(`[${res.code}] ${res.message}`)
    case 'loading': return null
  }
}

// --- Mapped & conditional types ---

type ReadOnly<T> = { readonly [K in keyof T]: T[K] }
type DeepPartial<T> = { [K in keyof T]?: T[K] extends object ? DeepPartial<T[K]> : T[K] }
type NonNullableFields<T> = { [K in keyof T]-?: NonNullable<T[K]> }

// Template literal types
type EventName<T extends string> = `on${Capitalize<T>}`
type ClickHandler = EventName<'click'>   // 'onClick'

// --- Class with generics ---

interface Repository<T, ID> {
  findById(id: ID): Promise<Nullable<T>>
  findAll(): Promise<T[]>
  save(entity: T): Promise<T>
  delete(id: ID): Promise<void>
}

interface User {
  id: number
  name: string
  email: string
  role: 'admin' | 'editor' | 'viewer'
  createdAt: Date
}

class InMemoryUserRepo implements Repository<User, number> {
  private store = new Map<number, User>()
  private counter = 0

  async findById(id: number): Promise<Nullable<User>> {
    return this.store.get(id) ?? null
  }

  async findAll(): Promise<User[]> {
    return Array.from(this.store.values())
  }

  async save(user: User): Promise<User> {
    if (!user.id) user = { ...user, id: ++this.counter }
    this.store.set(user.id, user)
    return user
  }

  async delete(id: number): Promise<void> {
    this.store.delete(id)
  }

  async findByRole(role: User['role']): Promise<User[]> {
    return (await this.findAll()).filter(u => u.role === role)
  }
}

// --- Event emitter with typed events ---

type EventMap = {
  userCreated: User
  userDeleted: { id: number }
  error: Error
}

class TypedEmitter<Events extends Record<string, unknown>> {
  private listeners = new Map<keyof Events, Set<(payload: unknown) => void>>()

  on<K extends keyof Events>(event: K, listener: (payload: Events[K]) => void): this {
    if (!this.listeners.has(event)) this.listeners.set(event, new Set())
    this.listeners.get(event)!.add(listener as (p: unknown) => void)
    return this
  }

  off<K extends keyof Events>(event: K, listener: (payload: Events[K]) => void): this {
    this.listeners.get(event)?.delete(listener as (p: unknown) => void)
    return this
  }

  emit<K extends keyof Events>(event: K, payload: Events[K]): void {
    this.listeners.get(event)?.forEach(fn => fn(payload))
  }
}

// --- Async generator ---

async function* paginate<T>(
  fetcher: (page: number, limit: number) => Promise<T[]>,
  limit = 20,
): AsyncGenerator<T[]> {
  let page = 1
  while (true) {
    const items = await fetcher(page++, limit)
    if (items.length === 0) return
    yield items
  }
}

// --- Usage ---

const emitter = new TypedEmitter<EventMap>()
const repo = new InMemoryUserRepo()

emitter.on('userCreated', user => console.log('created:', user.name))
emitter.on('error', err => console.error(err.message))

async function bootstrap() {
  const user = await repo.save({
    id: 0,
    name: 'Alice',
    email: 'alice@example.com',
    role: 'admin',
    createdAt: new Date(),
  })

  emitter.emit('userCreated', user)

  const { data, error } = await tryCatch(() => repo.findAll())
  if (error) {
    emitter.emit('error', error)
    return
  }

  console.log('all users:', data)

  for await (const page of paginate((p, l) => repo.findAll().then(u => u.slice((p-1)*l, p*l)))) {
    console.log('page:', page)
  }
}

bootstrap()
