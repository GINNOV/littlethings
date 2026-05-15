# os.getcwd

import os
import shutil
from distutils.dir_util import copy_tree

import sys
sys.path.append('/home/huenit/miraechar/ai-for-huenit')
from ai_training import setup_training, setup_inference, convert_to_xml

## SAVE_PATH, LABELS setting
MODEL_SAVE_PATH = "/home/huenit/miraechar/yolo_model_output"
TARGET_LABELS = "Human_face Mobile_phone Pen Computer_mouse"

os.chdir('/home/huenit/miraechar/OIDv4_ToolKit')
os.system("python3 main.py downloader --classes " + TARGET_LABELS + " --type_csv train -y --limit 20")
os.system("python3 main.py downloader --classes " + TARGET_LABELS + " --type_csv validation -y --limit 2")

check_target = TARGET_LABELS.split(" ")[0]

os.system("ls OID/Dataset/validation/" + check_target)
# change label list
with open("classes.txt", 'w') as f:
  for label in TARGET_LABELS.split(" "):
    f.write(label + "\n")
os.system("cat classes.txt")
os.system("rm -rf `find -type d -name .ipynb_checkpoints`")

def ignore_func(src, names):
    return ['env'] if 'env' in names else []

CLASS_DIRS = os.listdir("/home/huenit/miraechar/OIDv4_ToolKit/OID/Dataset")
for CLASS_DIR in CLASS_DIRS:
  print(CLASS_DIR + " processed")
  os.chdir("/home/huenit/miraechar/OIDv4_ToolKit/OID/Dataset/" + CLASS_DIR)
  CLASS_DIRS2 = os.listdir(os.getcwd())
  count = 0
  for CLASS_DIR2 in CLASS_DIRS2:
      print("=>" + CLASS_DIR2 + " processed")
      new_directory = CLASS_DIR + "2/"
      copy_tree(CLASS_DIR2 + "/", "../" + new_directory)

os.system("mkdir /home/huenit/miraechar/OIDv4_ToolKit/OID/Dataset_processed")
os.system("mkdir /home/huenit/miraechar/OIDv4_ToolKit/OID/Dataset_processed/data")
os.system("cp -r /home/huenit/miraechar/OIDv4_ToolKit/OID/Dataset/train2 /home/huenit/miraechar/OIDv4_ToolKit/OID/Dataset_processed/data")
os.system("cp -r /home/huenit/miraechar/OIDv4_ToolKit/OID/Dataset/validation2 /home/huenit/miraechar/OIDv4_ToolKit/OID/Dataset_processed/data")
convert_to_xml('/home/huenit/miraechar/OIDv4_ToolKit/OID/Dataset_processed/')

os.system("mkdir /home/huenit/miraechar/OIDv4_ToolKit/OID/xml_generated")
os.system("mkdir /home/huenit/miraechar/OIDv4_ToolKit/OID/xml_generated/anns")
os.system("mkdir /home/huenit/miraechar/OIDv4_ToolKit/OID/xml_generated/anns_validation")
os.system("mkdir /home/huenit/miraechar/OIDv4_ToolKit/OID/xml_generated/imgs")
os.system("mkdir /home/huenit/miraechar/OIDv4_ToolKit/OID/xml_generated/imgs_validation")

os.system("cp /home/huenit/miraechar/OIDv4_ToolKit/OID/Dataset_processed/data/train2/*.jpg /home/huenit/miraechar/OIDv4_ToolKit/OID/xml_generated/imgs")
os.system("cp /home/huenit/miraechar/OIDv4_ToolKit/OID/Dataset_processed/data/train2/*.xml /home/huenit/miraechar/OIDv4_ToolKit/OID/xml_generated/anns")
os.system("cp /home/huenit/miraechar/OIDv4_ToolKit/OID/Dataset_processed/data/validation2/*.jpg /home/huenit/miraechar/OIDv4_ToolKit/OID/xml_generated/imgs_validation")
os.system("cp /home/huenit/miraechar/OIDv4_ToolKit/OID/Dataset_processed/data/validation2/*.xml /home/huenit/miraechar/OIDv4_ToolKit/OID/xml_generated/anns_validation")

