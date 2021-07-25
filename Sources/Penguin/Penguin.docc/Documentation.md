# ``Penguin``

Create a unidirectional architecture pattern without depending on any reactive framework (e.g., Combine, etc.).

## Overview

Penguin provides components to create a unidirectional architecture pattern. The framework provides the main component ``Store``, which is responsible to maintain the current state at all times. A store contains an optional ``MiddlewareProtocol`` type and a ``Reducer``


## Topics

### Essentials

- ``Store``
- ``MiddlewareProtocol``
- ``Reducer``

### Middlewares 

- ``BaseMiddleware``
- ``LoggerMiddleware``
- ``PlaceholderMiddleware``

### Additional Components

- ``PassthroughElement``
- ``Initialisable``
