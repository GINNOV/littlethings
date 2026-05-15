import os
import xml.etree.ElementTree as ET
import numpy as np
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt

# 데이터셋 경로와 저장 경로 설정
dataset_path = '/home/huenit/miraechar/OIDv4_ToolKit/OID/xml_generated/anns'
output_path = '/home/huenit/miraechar/anchor_result/anchors.txt'
plot_output_path = '/home/huenit/miraechar/anchor_result/anchor_clustering_result.png'

# 바운딩 박스 너비와 높이 저장 리스트
widths = []
heights = []

# XML 파일 파싱 및 바운딩 박스 정보 추출
for xml_file in os.listdir(dataset_path):
    if xml_file.endswith('.xml'):
        tree = ET.parse(os.path.join(dataset_path, xml_file))
        root = tree.getroot()
        
        # 이미지 크기 가져오기
        image_width = int(root.find('size/width').text)
        image_height = int(root.find('size/height').text)
        
        # 모든 객체에 대한 바운딩 박스 정보 추출
        for obj in root.findall('object'):
            xmin = int(obj.find('bndbox/xmin').text)
            ymin = int(obj.find('bndbox/ymin').text)
            xmax = int(obj.find('bndbox/xmax').text)
            ymax = int(obj.find('bndbox/ymax').text)
            
            # 바운딩 박스의 너비와 높이 계산
            box_width = xmax - xmin
            box_height = ymax - ymin
            
            # 너비와 높이를 이미지 크기로 정규화
            normalized_width = box_width / image_width
            normalized_height = box_height / image_height
            
            # 리스트에 저장
            widths.append(normalized_width)
            heights.append(normalized_height)

# 너비와 높이를 배열로 변환
data = np.array(list(zip(widths, heights)))

# K-Means 클러스터링으로 앵커 박스 계산
num_anchors = 9  # 원하는 앵커 박스의 수
kmeans = KMeans(n_clusters=num_anchors, random_state=0).fit(data)
anchors = kmeans.cluster_centers_

# 정규화된 앵커 박스 정보를 지정된 경로에 저장
with open(output_path, 'w') as f:
    anchor_str = ', '.join([f"{w:.5f}, {h:.5f}" for w, h in anchors])
    f.write(f"anchors = ({anchor_str})\n")

# 클러스터링 결과 시각화
plt.figure(figsize=(10, 8))
plt.scatter(data[:, 0], data[:, 1], alpha=0.5, label='Bounding Boxes')
plt.scatter(anchors[:, 0], anchors[:, 1], color='red', marker='x', s=200, label='Anchors (K-Means Centers)')
plt.title('K-Means Clustering of Bounding Boxes')
plt.xlabel('Normalized Width')
plt.ylabel('Normalized Height')
plt.legend()
plt.grid(True)

# 그래프 저장
plt.savefig(plot_output_path)
plt.close()

# 이미지 크기 설정 
image_width = 244
image_height = 244

# 실제 앵커 박스 크기로 변환
actual_anchors = anchors * [image_width, image_height]

# 변환된 실제 앵커 박스 출력
print("Actual anchors (in pixels):")
for w, h in actual_anchors:
    print(f"Width: {w:.2f}, Height: {h:.2f}")

# 실제 앵커 박스를 출력 파일에 추가 저장
with open(output_path, 'a') as f:
    anchor_str_pixels = ', '.join([f"{w:.2f}, {h:.2f}" for w, h in actual_anchors])
    f.write(f"actual anchors (pixels) = ({anchor_str_pixels})\n")

print(f"Anchors saved to: {output_path}")
print(f"Clustering result plot saved to: {plot_output_path}")
