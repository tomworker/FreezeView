

https://github.com/user-attachments/assets/9f687c27-6e5e-4df1-8ba8-88326546d681

# FreezeView
**FreezeView** is a high-performance SwiftUI grid component that supports frozen headers (sticky rows and columns), designed for handling large datasets with smooth, inertial scrolling.

## ✨ Features
- **Frozen Headers:** Keep your top row and left column fixed while scrolling the main content.

- **On-Demand Rendering:** Only renders cells visible in the viewport, ensuring low CPU and memory usage even with thousands of rows.

- **Custom Inertial Scrolling:** Implements a smooth, UIKit-based pan gesture handling for a responsive feel.

- **Fully Customizable:** Inject any SwiftUI view for cells, headers, and the corner anchor using `@ViewBuilder'.

- ## 🚀 Usage
Integrating `FreezeScrollView` into your SwiftUI app is straightforward:

```Swift
import SwiftUI

struct MyGrid: View {
    var body: some View {
        FreezeScrollView(
            rowCount: 1000,
            columnCount: 100,
            cellSize: CGSize(width: 80, height: 40),
            freezeSize: CGSize(width: 100, height: 100),
            initialScroll: .zero,
            anchor: {
                Text("Corner").background(Color.gray)
            },
            col: { range, index in
                Text("Col \(index)").bold()
            },
            row: { range, index in
                Text("Row \(index)").bold()
            },
            cell: { rowRange, colRange, rowIdx, colIdx in
                Text("\(rowIdx), \(colIdx)")
            }
        )
    }
}
```
## 🛠 Architecture
The project is built on three core pillars:

1. `FreezeScrollView`: The main container that manages the Z-stacking of headers and content.

2. `ScOffset`: A `StateObject` that calculates visible ranges and manages the math behind inertial scrolling.

3. `ScOffsetView`: A `UIViewControllerRepresentable` that bridges UIKit's `UIPanGestureRecognizer` into the SwiftUI environment for precise control.

## ⚙️ Requirements
- iOS 15.0+ / macOS 12.0+

- Swift 5.5+

- Xcode 13.0+

## 📝 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Created by **tomworker**
