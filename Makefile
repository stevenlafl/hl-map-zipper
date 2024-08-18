IMAGE_NAME=hl-map-zipper

build:
	docker build -t ${IMAGE_NAME} .
debug:
	docker run -it --rm \
	--entrypoint /bin/bash \
	-v /media/Data1/SteamLibrary/steamapps/common/Half-Life/ts:/input:ro \
	-v $(PWD)/output:/output \
	${IMAGE_NAME}
run:
	docker run -it --rm \
	-v /media/Data1/SteamLibrary/steamapps/common/Half-Life/ts:/input:ro \
	-v $(PWD)/output:/output \
	${IMAGE_NAME}
test:
	docker run -it --rm \
	-v $(PWD)/input:/input:ro \
	-v $(PWD)/output:/output \
	${IMAGE_NAME}