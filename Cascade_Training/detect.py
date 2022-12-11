import cv2

# Load the cascade file
cascade = cv2.CascadeClassifier('cascade_manual_2/cascade.xml')

address = "http://192.168.178.68:81/stream"

cap = cv2.VideoCapture(address)

# Loop until the user presses the 'q' key
while True:
    # Read a frame from the video
    ret, frame = cap.read()

    # Check if a frame was read successfully
    if not ret:
        break

    # Detect objects in the frame using the cascade file
    objects = cascade.detectMultiScale(frame, 1.2, 5)

    # Draw a bounding box around each detected object
    for (x, y, w, h) in objects:
        cv2.rectangle(frame, (x, y), (x + w, y + h), (255, 0, 0), 2)

    # Show the output frame
    cv2.imshow('frame', frame)

    # Check if the user pressed the 'q' key
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

# Release the video capture object and close all windows
cap.release()
cv2.destroyAllWindows()
