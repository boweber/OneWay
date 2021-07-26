extension Array {
    mutating func removeFirstTransformableElements<NewElement>(_ transform: (Element) -> NewElement?) -> [NewElement] {
        var transformed: [NewElement] = []
        for (index, element) in self.enumerated() {
            if let newElement = transform(element) {
                transformed.append(newElement)
            } else {
                if transformed.isEmpty { return transformed }
                self = Array(dropFirst(index - 1))
                return transformed
            }
        }
        self = []
        return transformed
    }
}
