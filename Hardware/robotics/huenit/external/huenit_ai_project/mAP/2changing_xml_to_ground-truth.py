import os
import xml.etree.ElementTree as ET


'''정답 바운딩 박스 위치'''
# XML 파일이 저장된 폴더
xml_folder = '/home/huenit/miraechar/OIDv4_ToolKit/OID/xml_generated/anns_validation'

# 결과를 저장할 폴더
output_folder = '/home/huenit/miraechar/mAP/input/ground-truth'
os.makedirs(output_folder, exist_ok=True)


# XML 파일을 변환하는 함수
def convert_xml_to_txt(xml_file, output_folder):
    # XML 파일 파싱
    tree = ET.parse(xml_file)
    root = tree.getroot()
    
    # 파일 이름 추출
    filename = root.find('filename').text.replace('.jpg', '.txt')
    
    # 결과를 저장할 txt 파일 경로
    output_file = os.path.join(output_folder, filename)
    
    with open(output_file, 'w') as f:
        # 각 object에 대해 변환된 데이터를 작성
        for obj in root.findall('object'):
            class_name = obj.find('name').text
            difficult = obj.find('difficult').text
            
            # 바운딩 박스 정보 추출
            bndbox = obj.find('bndbox')
            left = bndbox.find('xmin').text
            top = bndbox.find('ymin').text
            right = bndbox.find('xmax').text
            bottom = bndbox.find('ymax').text
            
            # 결과 포맷 설정
            if difficult == '1':
                formatted_line = f"{class_name} {left} {top} {right} {bottom} difficult\n"
            else:
                formatted_line = f"{class_name} {left} {top} {right} {bottom}\n"
            
            # 결과를 파일에 작성
            f.write(formatted_line)

# XML 폴더에 있는 모든 XML 파일을 변환
for xml_file in os.listdir(xml_folder):
    if xml_file.endswith('.xml'):
        full_xml_path = os.path.join(xml_folder, xml_file)
        convert_xml_to_txt(full_xml_path, output_folder)

print(f"Converted data has been saved to: {output_folder}")
