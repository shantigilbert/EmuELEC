BUILD_DIRS=build.*

all: release

system:
	./scripts/image

release:
	./scripts/image release

image:
	ARCH=arm ARCH_PARENT=$(ARCH) ./scripts/build_arm
	./scripts/image mkimage

noobs:
	./scripts/image noobs

clean:
	rm -rf $(BUILD_DIRS)/* $(BUILD_DIRS)/.stamps

distclean:
	rm -rf ./.ccache ./$(BUILD_DIRS)

src-pkg:
	tar cvJf sources.tar.xz sources
