# ``OneWay``

Create a unidirectional architecture pattern without depending on any reactive framework (e.g., Combine, etc.).

## Overview

OneWay provides components to create a unidirectional architecture pattern. The framework provides the main component ``Store``, which is responsible to maintain the current state at all times. A store contains an optional ``MiddlewareProtocol`` type and a ``Reducer``.

![one way](oneway.png)

[Christopher Strolia-Davis](https://pixabay.com/users/ingagestroliac-968028/?utm_source=link-attribution&utm_medium=referral&utm_campaign=image&utm_content=759223)

## Topics

### Essentials

- ``Store``
- ``MiddlewareProtocol``
- ``Reducer``

### Middlewares 

- ``BaseMiddleware``
- ``LoggerMiddleware``
- ``PlaceholderMiddleware``

### Utilities

- ``PassthroughElement``
- ``Initialisable``
- ``Tracing``

### Logging

- ``LoggerProtocol``
- ``LoggingContext``
