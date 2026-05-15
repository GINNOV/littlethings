## SAVE_PATH, LABELS setting
MODEL_SAVE_PATH = "/home/huenit/miraechar/yolo_model_output"
TARGET_LABELS = "Human_face Mobile_phone Pen Computer_mouse"


import sys
sys.path.append('/home/huenit/miraechar/ai-for-huenit')
from ai_training import setup_training, setup_inference, convert_to_xml

label_list = []
for label in TARGET_LABELS.split(" "):
  label_list.append(label)


#  Full Yolo, Tiny Yolo, MobileNet1_0, MobileNet7_5, MobileNet5_0, MobileNet2_5, SqueezeNet, NASNetMobile, ResNet50, DenseNet121
config = {
    "model":{
        "type":                 "Detector",
        "architecture":         "MobileNet5_0",
        "input_size":           [224, 224],
        "anchors":              [[[1.889, 2.5245], [2.9465, 3.94056], [3.99987, 5.3658], [5.155437, 6.92275], [6.718375, 9.01025]]],
        "labels":               label_list,
        "obj_thresh" : 		    0.5,
        "iou_thresh" : 		    0.5,
        "coord_scale" : 		1.0,
        "object_scale" : 		5.0,
        "no_object_scale" :     1.0
    },
    "weights" : {
        "full":   				"",
        "backend":   		    "imagenet"   
    },
    "train" : {
        "actual_epoch":         20,
        "train_image_folder":   "/home/huenit/miraechar/OIDv4_ToolKit/OID/xml_generated/imgs",
        "train_annot_folder":   "/home/huenit/miraechar/OIDv4_ToolKit/OID/xml_generated/anns",
        "train_times":          5,
        "valid_image_folder":   "/home/huenit/miraechar/OIDv4_ToolKit/OID/xml_generated/imgs_validation",
        "valid_annot_folder":   "/home/huenit/miraechar/OIDv4_ToolKit/OID/xml_generated/anns_validation",
        "valid_times":          1,
        "valid_metric":         "recall",
        "batch_size":           8,
        "learning_rate":        1e-3,
        "saved_folder":   		MODEL_SAVE_PATH,
        "first_trainable_layer": "",
        "augmentation":				True,
        "is_only_detect" : 		False,
        "generate_script":    True
    },
    "converter" : {
        "type":   				["k210"]
    }
}

### Train start ###
# I modified fit.py in optimizer(legacy optimizer is not used)
#import os
#os.environ["TF_USE_LEGACY_KERAS"] = "True"
#import tf_keras as keras
#from tf_keras.optimizers import legacy

import tensorflow as tf
print("Num GPUs Available: ", len(tf.config.list_physical_devices('GPU')))
from ai_training import setup_training, setup_inference
from keras import backend as K
#K.tensorflow_backend._get_available_gpus()
K.clear_session()
model_path = setup_training(config_dict=config)

import os
os.system("matplotlib inline")
from keras import backend as K
K.clear_session()
setup_inference(config, model_path)










