# Contributing to CS2Panel

Thank you for considering contributing to CS2Panel! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help create a welcoming environment
- Report unacceptable behavior to conduct@cs2panel.example.com

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports:
- Check the existing issues to avoid duplicates
- Collect relevant information (logs, screenshots, etc.)

When creating a bug report, include:
- **Clear title** describing the issue
- **Steps to reproduce** the problem
- **Expected behavior** vs actual behavior
- **Environment details** (OS, Java version, etc.)
- **Logs or error messages**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. Include:
- **Use case** - Why is this enhancement needed?
- **Proposed solution** - How should it work?
- **Alternatives considered** - What other solutions did you think about?
- **Additional context** - Screenshots, mockups, etc.

### Pull Requests

1. **Fork the repository** and create your branch from `develop`
   ```bash
   git checkout -b feature/amazing-feature
   ```

2. **Make your changes**
   - Follow the coding standards
   - Write tests for new features
   - Update documentation

3. **Test your changes**
   ```bash
   # Backend tests
   cd backend && mvn test

   # Hypervisor tests
   cd hypervisor && go test ./...
   ```

4. **Commit your changes**
   ```bash
   git commit -m "feat: add amazing feature"
   ```

   Use conventional commits:
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation changes
   - `style:` - Code style changes
   - `refactor:` - Code refactoring
   - `test:` - Adding tests
   - `chore:` - Maintenance tasks

5. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```

6. **Open a Pull Request**
   - Provide a clear description
   - Reference related issues
   - Add screenshots if applicable

## Development Setup

See [README.md](README.md#-quick-start) for detailed setup instructions.

Quick start:
```bash
# Clone your fork
git clone https://github.com/your-username/cs2panel.git
cd cs2panel

# Setup environment
./scripts/dev-setup.sh

# Run tests
cd backend && mvn test
cd ../hypervisor && go test ./...
```

## Coding Standards

### Java/Spring Boot

- Follow standard Java conventions
- Use Lombok annotations where appropriate
- Write JavaDoc for public APIs
- Maximum line length: 120 characters
- Use meaningful variable names
- Extract magic numbers to constants

Example:
```java
@Service
@RequiredArgsConstructor
@Slf4j
public class ExampleService {

    private final ExampleRepository repository;

    /**
     * Retrieves an example by ID.
     *
     * @param id the example ID
     * @return the example entity
     * @throws NotFoundException if example not found
     */
    public Example getById(Long id) {
        return repository.findById(id)
            .orElseThrow(() -> new NotFoundException("Example not found"));
    }
}
```

### Go

- Follow Go conventions (`gofmt`, `go vet`)
- Write tests for all functions
- Use meaningful package names
- Document exported functions
- Handle errors explicitly

Example:
```go
// CreateVM creates a new virtual machine with the specified parameters
func (m *Manager) CreateVM(name string, cpuCores, memoryMB, diskGB int) (*VM, error) {
    if name == "" {
        return nil, fmt.Errorf("VM name cannot be empty")
    }

    vm := &VM{
        UUID:     uuid.New().String(),
        Name:     name,
        CPUCores: cpuCores,
        MemoryMB: memoryMB,
        DiskGB:   diskGB,
    }

    if err := m.db.Create(vm).Error; err != nil {
        return nil, fmt.Errorf("failed to create VM: %w", err)
    }

    return vm, nil
}
```

## Testing

### Backend Tests

```bash
cd backend

# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=AuthServiceTest

# Run with coverage
mvn test jacoco:report
```

### Hypervisor Tests

```bash
cd hypervisor

# Run all tests
go test ./...

# Run with coverage
go test -cover ./...

# Run specific test
go test -run TestCreateVM ./vm
```

### Integration Tests

```bash
# Start test environment
docker-compose -f docker-compose.test.yml up -d

# Run integration tests
cd backend && mvn verify

# Cleanup
docker-compose -f docker-compose.test.yml down
```

## Documentation

- Update README.md for user-facing changes
- Add JavaDoc/GoDoc for new public APIs
- Update OpenAPI/Swagger annotations
- Include examples in documentation

## Review Process

1. Automated checks must pass (CI/CD)
2. Code review by at least one maintainer
3. All conversations must be resolved
4. Branch must be up to date with target branch

## Release Process

Releases follow semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes (backward compatible)

## Questions?

- Open an issue for discussion
- Join our Discord: https://discord.gg/cs2panel
- Email: dev@cs2panel.example.com

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

Thank you for contributing! 🎉
