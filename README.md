# Infinite-Produce
A To-Do List mobile application (2018)

📖🖊 Infinite Produce is a To Do List mobile application implemented in Java for Android and in Swift for iOS as a personal project. It connects to Firebase for database management and image storage.

The application allows the user to add new to do items, edit them later, delete them, reorder them, mark them as finished, and add notes to them. It can also show the user a random image with a motivational quote.The user is required to provide a one-time username which is used to link their to do items in the Firebase database (Firestore).The user may enter this username again if they change phones or delete the application to relink the current device to their stored to do items.

The structure of the database follows this shape: `Collection("Users").document(//UserID).Collection("Todos").document(//TodoID)`
and each to do has a name, a note, a state (completed or not), and an order (for displaying).

Screenshots and videos can be found here: https://malaksadek.wordpress.com/2019/08/31/infiniteproduce-do-everything/

# Download the App

The app is available on:
* The iOS App Store: https://apps.apple.com/gb/app/infiniteproduce-do-everything/id1478504715
* The Google Play Store: https://apps.apple.com/gb/app/infiniteproduce-do-everything/id1478504715

# Contact

* email: mfzs1@st-andrews.ac.uk
* LinkedIn: www.linkedin.com/in/malak-sadek-17aa65164/
* website: https://malaksadek.wordpress.com/
