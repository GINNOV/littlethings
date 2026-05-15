import json
import os

# Load the prediction JSON file
pred_json_path = '/home/huenit/miraechar/yolo_model_output/2024-10-24_12-14-46/Inference_results/pred_boxes.json'

# Extract the timestamp from the pred_json_path
timestamp_folder = pred_json_path.split('/')[-3]  # This will extract '2024-09-20_12-56-13'

# Set the output folder using the extracted timestamp
output_folder = f'/home/huenit/miraechar/mAP/input/detection-results/{timestamp_folder}'

# Ensure the output folder exists
os.makedirs(output_folder, exist_ok=True)

# Load the JSON data
with open(pred_json_path, 'r') as f:
    pred_data = json.load(f)

# Process each image and its bounding boxes
for image_id, boxes in pred_data.items():
    # Remove the file extension (.jpg) for the output filename
    output_file_name = os.path.splitext(image_id)[0] + ".txt"
    output_file_path = os.path.join(output_folder, output_file_name)
    
    # Open the output file to write the results
    with open(output_file_path, 'w') as out_file:
        for box_info in boxes:
            class_name = box_info['class']
            confidence = box_info['score']  # Keep confidence as a float
            left, top, right, bottom = box_info['box']

            # Format the data as desired (no percentage for confidence)
            formatted_line = f"{class_name} {confidence:.6f} {left} {top} {right} {bottom}\n"
            out_file.write(formatted_line)

print(f"Converted data has been saved to: {output_folder}")
