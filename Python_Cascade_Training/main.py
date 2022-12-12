import cv2
import datetime
import os

address = "http://192.168.178.68:81/stream"

cap = cv2.VideoCapture(address)

# Create the "data" folder if it doesn't exist
if not os.path.exists('data'):
    os.makedirs('data')

while True:
    # Capture frame-by-frame
    ret, frame = cap.read()

    # Display the resulting frame
    cv2.imshow('IP Camera', frame)

    # Check if the user pressed the spacebar
    key = cv2.waitKey(1)
    if key == ord(' '):
        # Save the image
        filename = datetime.datetime.now().strftime("%Y%m%d-%H%M%S") + ".jpg"

        # Save the image
        cv2.imwrite(os.path.join('data', filename), frame)
        print("image saved as: " + filename)

    # Check if the user pressed the 'q' key
    if key == ord('q'):
        break

# Release the VideoCapture object
cap.release()
cv2.destroyAllWindows()