# 🤖 GeminiOps-Assistant

An advanced AI assistant built using Google’s generative models (**Gemini 2.5/2.0/1.5**) to automate tasks, answer queries, and support intelligent workflows with real-time reasoning and tool integration.

## ✨ Key Features

- **🧠 Multi-Model Intelligence**: Seamlessly switch between Gemini 2.5 Flash, Pro, and 1.5 versions for different reasoning depths.
- **📁 GeminiOps Projects**: Organize your AI interactions into high-level Projects (Folders) for focused workflows.
- **🖼️ Premium Branding**: Features a procedurally animated neural logo and a sleek "Light Mode First" aesthetic.
- **⚡ Real-time Streaming**: Experience lightning-fast responses with word-by-word streaming technology.
- **📱 Multi-Session Management**: Just like ChatGPT, manage dozens of concurrent chats with automatic title generation.

## 🛠️ Technology Stack

- **Core**: Flutter (Material 3)
- **State Management**: Riverpod 3 (Modern Notifiers)
- **AI Engine**: Google Generative AI (Gemini API)
- **Typography/Animations**: Google Fonts (Outfit & Inter), Animate-do
- **Theming**: Premium Slate & Indigo Light Theme

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Latest Stable)
- Google Gemini API Key

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/GeminiOps-Assistant.git
   cd GeminiOps-Assistant
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure API Key**:
   Open `lib/providers/chat_provider.dart` and update the `_defaultApiKey` constant.

4. **Run the App**:
   ```bash
   flutter run
   ```

## 📱 App Structure

- `lib/models/`: Data structures for Projects, Sessions, and Messages.
- `lib/providers/`: Riverpod state management for history and AI streaming.
- `lib/screens/`: High-end UI screens including Splash and Chat interfaces.
- `lib/widgets/`: Reusable components like the `AILogo` and `ChatHistoryDrawer`.

---
*Built for intelligent workflows and seamless AI integration.*
