# club8
1. Experience Type Selection Screen
This screen allows the host applicant to select the types of events or social gatherings they have experience facilitating.

API Integration: Fetches a dynamic list of available experiences from the provided endpoint: https://staging.chamberofsecrets.8club.co/v1/experiences?active=true using Dio.

Experience Card Display: Each experience is presented using its image_url as a background image, maintaining a clean UI with proper spacing and styling.

Multi-Selection Logic:

Users can select multiple experience cards.

Selection State Visuals: Selected cards are displayed in full color, while unselected cards are shown with a grayscale filter on the background image.

Text Input Field: Includes a multi-line text field for additional context with a strict character limit of 250.

State Management: Stores the IDs of the selected experiences and the text input in the application state, implemented using Riverpod.

Navigation: On clicking the "Next" button, the current state (selected experience IDs and text) is logged to the console, and the user is securely navigated to the Onboarding Question Screen.

2. Onboarding Question Screen
This screen allows the applicant to provide detailed, multi-format answers to a central question.

Long-form Text Input: Features a multi-line text field for a textual answer, enforced with a character limit of 600.

Audio Recording Support:

Allows the user to record an audio answer.

During recording, a visual waveform is displayed.

Provides an option to cancel the recording process.

Allows the user to delete a previously recorded audio file.

The recorded audio file is saved to the app's local cache.

Video Recording Support:

Allows the user to record a video answer.

Provides an option to delete a previously recorded video file.

The video is recorded and saved in the local cache of the app.

Dynamic Layout Visuals: The UI intelligently adapts based on the recorded assets:

The "Record Audio" and "Record Video" buttons are dynamically removed from the bottom of the screen once the corresponding asset has been successfully recorded and saved.

🛠️ Project Structure and Technology
The project adheres to a scalable structure for easy maintenance and future expansion:

/lib

/screens: Holds all major screen widgets (ExperienceSelectionScreen, QuestionScreen).

/models: Contains data models (e.g., ExperienceModel).

/services: Manages API calls (ApiService).

/widgets: Reusable UI components (e.g., ExperienceCard, RecordingControls).

/providers: Riverpod state management logic.

State Management: Riverpod is used for efficient and predictable state handling across the application.

Networking: Dio is utilized as the HTTP client for all API interactions.

📹 Working Demo
A short demo clip showcasing the application's functionalities, including experience selection, text input, audio recording with cancellation, and video recording, is attached for review. The video shows that upon recording, the files are saved in the local cache of the app.

https://github.com/user-attachments/assets/15c6549b-e628-4498-b61e-72843318faf5

