# Object Detective App

## Introduction

Object Detective is a Flutter-based mobile application that enables users to detect specific objects in real-time using the device camera. It leverages Google ML Kit for object detection and provides instant feedback, including zooming suggestions, to ensure accurate recognition. The app is designed for both efficiency and ease of use.


## Diagram of the Flow

![Screenshot 2025-02-02 124623](https://github.com/user-attachments/assets/50860bbf-5fc5-485d-b5ca-7d2eec83ee82)


## Steps and Logic Explanation

1. **Home Screen**

   - Displays a list of objects (Laptop, Mobile Phone, Mouse, Bottle).
   - User selects an object, which is stored in `ObjectProvider`.
   - Navigates to `CameraScreen`.

2. **Camera Screen**

   - Initializes the camera and starts an image stream.
   - Uses `ObjectDetectionService` to detect the selected object.
   - Provides real-time feedback:
     - "🔍 Detecting...": The app is scanning for the object.
     - "🔍 Zoom In": The object is detected but appears too small.
     - "🔍 Zoom Out": The object is too close to the camera.
     - "✅ Object Detected": The object is identified correctly.
   - If an object is detected, an image is automatically captured and sent to `ResultScreen`.

3. **Detection Logic**

   - The detection process occurs in **two steps** due to the nature of Google ML Kit:
     1. **First Step**: Google ML Kit detects the general category of the object (e.g., "Home Goods" instead of specific objects like "Laptop").
     2. **Second Step**: The detected object is cropped using its bounding box and passed through a secondary labeling process to classify the specific object.
   - The labeled cropped image is compared against the selected object label to ensure a correct match.
   - The size of the object within the frame is checked:
     - If the object's width or height is less than **60%** of the image size, the app instructs to **Zoom In**.
     - If the object's width or height is more than **90%**, the app instructs to **Zoom Out**.
     - Otherwise, the object is **successfully detected**.

4. **Result Screen**

   - Displays the captured image.
   - Shows the timestamp of when the image was taken.
   - Provides an option to go back to the home screen to restart the process.

## Detailed Features

- **Real-time Object Detection**: Uses ML Kit’s object detection API to identify objects.
- **Two-Step Detection Process**: First detects general object categories, then refines classification.
- **Automated Image Capture**: Once an object is detected, an image is captured automatically.
- **User-Friendly UI**: Simple and intuitive interface for easy interaction.
- **Zoom Instructions**: Guides users to adjust their camera distance for better detection accuracy.

## Requirements

- **System Requirements**:

  - Flutter SDK (>=3.1.5)
  - Dart SDK
  - Android 8.0+ / iOS 12.0+

- **Dependencies**:

  - `camera` (for camera access)
  - `google_ml_kit` (for object detection)
  - `image` (for image processing)
  - `provider` (for state management)
  - `path_provider` (for file storage)

## How to Run

1. **Clone the Repository**

   ```sh
   git clone [<repository-url>](https://github.com/marambakar/nova-it-assessment.git)
   cd nova_it_assessment
   ```

2. **Install Dependencies**

   ```sh
   flutter pub get
   ```

3. **Run the App**

   ```sh
   flutter run
   ```

4. **Usage Instructions**

   - Open the app and select an object from the home screen.
   - Allow camera permissions when prompted.
   - Hold the camera steady towards the object.
   - Follow the zoom instructions if needed.
   - Once detected, the image will be captured and displayed.


## How We Can Improve

- **Testing Alternative Detection Models**: The current detection method requires two steps because Google ML Kit provides broad classifications. However, models like **SSD MobileNet** might allow single-step detection since they include specific labels.
- **Implementing and Comparing Approaches**: The best way to improve the app is to implement both the current two-step method and the SSD MobileNet model, then compare the results in terms of:
  - **Accuracy**: How precise is the detection?
  - **Performance**: How fast is the detection process?
  - **Resource Usage**: Which approach is more efficient on mobile devices?

By analyzing these factors, we can determine the most effective object detection method for future updates.


