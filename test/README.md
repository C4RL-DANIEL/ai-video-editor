# Test Configuration

## Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Service layer business logic
- Utility functions
- Validators

### Widget Tests
- Shared widget rendering
- Form validation
- Navigation flows

### Integration Tests
- Upload flow
- Analysis pipeline
- Shorts generation
- Export flow

## Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/models/project_test.dart

# Run integration tests
flutter drive --target=test_driver/integration_test.dart
```

## Test Scenarios
Based on the master build prompt:

1. Short/long sources
2. Missing audio
3. Multiple audio tracks
4. Different FPS/resolutions
5. Vertical/horizontal sources
6. Corrupted inputs
7. Large inputs
8. Subtitles
9. Faces
10. Multiple speakers
11. Rapid scene changes
