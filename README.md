
🌿 Plant Disease Detection App

A powerful Flutter-based mobile application that detects plant diseases using a trained TFLite model and provides solutions in English and Urdu using Gemini API. Designed to assist farmers, researchers, and agriculture professionals with real-time, offline disease detection and multilingual recommendations.

🚀 Features

📷 Take a photo or select one from gallery to detect disease.

🤖 Offline prediction using a trained TFLite model.

🌐 Gemini API integration for providing:

📌 Disease causes

💡 Solutions in English and Urdu

🧠 Lightweight and fast model inference

💚 Simple and intuitive UI

📸 Screenshots

🛠️ Tech Stack

Flutter 🐦

TFLite for on-device ML inference

Gemini API for generating disease solutions

image_picker for selecting images

cupertino_icons for iOS-styled icons

📦 Dependencies
dependencies:
flutter:
sdk: flutter

cupertino_icons: ^1.0.2

image_picker: ^0.8.9

flutter_tflite: ^1.0.1

📁 Project Setup

To set up and run the project on your local machine, follow these steps:

1. Clone the Repository
   git clone https://github.com/developer-ahmed1/plant-disease-detection.git
   cd plant-disease-detection-flutter

2. Get Flutter Packages

    flutter pub get

3. Add Assets
   Make sure the following assets are placed properly:

Your trained .tflite model in:


assets/model/model.tflite

The corresponding labels in:

assets/model/labels.txt


Update your pubspec.yaml:

flutter:
assets:
- assets/model/model.tflite
- assets/model/labels.txt

4. API Key for Gemini
   Set up your Gemini API key securely. You can either use:

.env file with flutter_dotenv, or

Place it in a config file (not recommended to commit it)

Example .env:

GEMINI_API_KEY=your_api_key_here
🧪 Usage
Launch the app.

Tap to pick or take an image.

The app will run inference using the TFLite model.

Detected disease name is passed to Gemini API.

Gemini responds with disease causes and solutions in English and Urdu.

🌐 Gemini API Integration

Gemini is used to provide relevant solutions in two languages. Prompt example sent to API:

"Explain the causes and solutions for Tomato Leaf Curl Virus in both English and Urdu."
Response is parsed and displayed on a solution screen with clear formatting.

📱 Platform Support
✅ Android (Tested)

🚧 iOS (Planned)

🙌 Contributing
We welcome contributions! Please open an issue or submit a pull request with improvements or feature ideas.

📃 License
This project is licensed under the MIT License.

👨‍💻 Author
Muhammad Ahmed Nadeem

For queries or suggestions: ahmednadeemarain.75@gmail.com
