/* Usage: evkill <-k, --keys keys> <-d, --device evdev> <programs>
eg: evkill -k 304+305 -d /dev/input/event3 retroarch

Signed-off-by: Ning Bo <n.b@live.com> 
*/

#define _GNU_SOURCE

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <getopt.h>
#include <fcntl.h>
#include <linux/input.h>
#include <dirent.h>
#include <libgen.h>
#include <sys/inotify.h>

char *bin_name;
char *device;
char *file;
char *bitmap0, *bitmap1;
int bitmap_valid = 0;
int bitmap_size = (KEY_CNT - 1) / 8 + 1;
char cmd[1024];

void set_bit(char *mem, int key) {
	int8_t *byte = (int8_t *)mem + key / 8;
	*byte |= 1 << key % 8;
}

void clr_bit(char *mem, int key) {
	int8_t *byte = (int8_t *)mem + key / 8;
	*byte &= ~(1 << key % 8);
}

static const struct option long_options[] = {
	{"device", required_argument, NULL, 'd'},
	{"keys", required_argument, NULL, 'k'},
	{"file", required_argument, NULL, 'f'},
	{0, 0, 0, 0}
};

void usage() {
	printf("\
Usage: %s [OPTION] PROGRAM...\n", bin_name);
	printf("\
Listen the input event of device and kill the programs specified.\n");
	printf("\
  -d, --device=DEVICE                    listen input event from\n");
	printf("\
  -k, --keys=[key0,key1..|key0+key1...]  the keys combo number. Only effect when --file not specify\n");
	printf("\
  -f, --file=FILE                        the configuration file include the keys combo\n");
}

char *js2evdev(char *joystick) {
	char *evdev = NULL;
	char *path = NULL;
	DIR *dir;
	struct dirent *ptr;

	asprintf(&path, "/sys/class/input/%s/device", basename(joystick));
	dir = opendir(path);
	free(path);
	if (dir == NULL) {
		return NULL;
	}

	while((ptr = readdir(dir)) != NULL) {
		if (ptr->d_type == DT_DIR && strncmp(ptr->d_name, "event", 5) == 0) {
			asprintf(&evdev, "/dev/input/%s", ptr->d_name);
		}
	}

	return evdev;
}

void parse_keys(char *keys) {
	char *str, *saveptr, *key;
	int i;

	if (!bitmap0) bitmap0 = (char *)malloc(bitmap_size);
	if (!bitmap1) bitmap1 = (char *)malloc(bitmap_size);
	memset(bitmap0, 0x0, bitmap_size);
	memset(bitmap1, 0x0, bitmap_size);
	bitmap_valid = 0;

	for (i = 0, str = keys; ; i++, str = NULL) {
		key = strtok_r(str, ",+", &saveptr);
		if (key == NULL)
			break;

		if (atoi(key) > KEY_MAX)
			continue;

		set_bit(bitmap0, atoi(key));
		bitmap_valid = 1;
		printf("## %d\n", atoi(key));
	}
}

int reload_file(char *file) {
	FILE *fp;
	char *line = NULL;
	size_t len = 0;
	ssize_t read;
	const char *keys = "EE_KILLKEYS";
	const char *dev = "EE_EE_KILLDEV";
	char *value;

	fp = fopen(file, "r");
	if (fp == NULL) {
		printf("open %s failed: %s\n", file, strerror(errno));
		return -1;
	}

	while ((read = getline(&line, &len, fp)) != -1) {
		if (strncmp(line, keys, strlen(keys)) == 0) {
			/* eat '"' */
			value = line + strlen(keys);
			while (*value++) {
				if (*value != '"')
					break;
			}
			parse_keys(value);
			continue;
		}
		if (strncmp(line, dev, strlen(dev)) == 0) {
			/* eat '"' */
			value = line + strlen(dev);
			while (*value++) {
				if (*value != '"')
					break;
			}
			char *p = strchr(value, '"');
			if (p) *p = 0;
			device = value;
			continue;
		}
	}

	fclose(fp);
	if (line) free(line);

	return 0;
}

int parse_args(int argc, char *argv[]) {
	int opt = 0;
	char *keys = NULL;

	bin_name = strdup(basename(argv[0]));

	while((opt = getopt_long(argc, argv, "d:k:f:", long_options, NULL)) != -1)
	{
		switch(opt)
		{
			case 'd':
				device = strdup(optarg);
				break;
			case 'k':
				keys = strdup(optarg);
				break;
			case 'f':
				file = strdup(optarg);
				break;
			default:
				usage();
				return -1;
		}
	}

	if (file == NULL) {
		if (device == NULL || keys == NULL) {
			usage();
			return -1;
		}
	}

	/* failed if no program specified */
	if (optind == argc) {
		usage();
		return -1;
	}

	memset(cmd, 0, sizeof(cmd));
	strcpy(cmd, "killall ");
	int i;
	for (i = optind; i < argc; i++) {
		strcat(cmd, argv[i]);
	}

	if (file) {
		if (reload_file(file) < 0) {
			return -1;
		}
	} else {
		parse_keys(keys);
	}

	return 0;
}

int monitor_setup(char *file) {
	int fd = inotify_init();
	if (fd < 0) {
		perror("inotify_init failed");
		return -1;
	}

	int wd = inotify_add_watch(fd, file, IN_MODIFY);
	if (wd < 0) {
		perror("inotify_add_watch failed");
		return -1;
	}

	return fd;
}

int open_device(char *dev) {
	int fd;

	for (;;) {
		int version, ready;

		ready = 0;
		do {
			fd = open(dev, O_RDONLY);
			if (fd > 0) {
				if (ioctl(fd, EVIOCGVERSION, &version)) {
					ready = 1;
					break;
				}
			}
			printf("open %s failed\n", dev);

			char *evdev = js2evdev(dev);
			if (!evdev) {
				break;
			}

			fd = open(evdev, O_RDONLY);
			free(evdev);
			if (fd > 0) {
				if (ioctl(fd, EVIOCGVERSION, &version) == 0) {
					ready = 1;
					break;
				}
			}
			printf("open %s failed\n", evdev);
		} while(0);

		
		if (ready) {
			break;
		}
		sleep(1);
	}

	return fd;
}

int listen_input_event(int fd, int monitor_fd) {
	int ret = 0;
	struct input_event input_event;
	struct inotify_event inotify_event;
	fd_set fds;
	FD_ZERO(&fds);
	int max_fd = fd > monitor_fd ? fd : monitor_fd;

	for (;;) {
		FD_SET(fd, &fds);
		if (monitor_fd > 0) FD_SET(monitor_fd, &fds);

		ret = select(max_fd + 1, &fds, NULL, NULL, NULL);
		if (ret < 0) {
			perror("select failed");
			return -1;
		}

		if (monitor_fd > 0 && FD_ISSET(monitor_fd, &fds)) {
			printf("reload configuration from file\n");
			ret = read(monitor_fd, &inotify_event, sizeof(inotify_event));
			if (reload_file(file) < 0) {
				printf("reload configuration from file failed\n");
			}
		}
		if (FD_ISSET(fd, &fds)) {
			printf("input event\n");
			ret = read(fd, &input_event, sizeof(input_event));
			if (ret < 0) {
				perror("read");
				break;
			}

			if (input_event.type == EV_KEY) {
				if (input_event.value == 0) {
					clr_bit(bitmap1, input_event.code);
					continue;
				} else {
					set_bit(bitmap1, input_event.code);
				}
			}

			if (bitmap_valid != 0 && memcmp(bitmap0, bitmap1, bitmap_size) == 0) {
				memset(bitmap1, 0x0, bitmap_size);
				/* printf("execute cmd: %s\n", cmd);*/
				system(cmd);
				//exit(0);
			}
		}
	}

	return 0;
}

int main(int argc, char* argv[])
{
	int ret = 0;
	int monitor_fd = 0;

	ret = parse_args(argc, argv);
	if (ret < 0) {
		return -1;
	}

	if (file) {
		monitor_fd = monitor_setup(file);
		if (monitor_fd < 0) {
			printf("monitori_setup failed\n");
			return -1;
		}
	}

	int fd = open_device(device);

	listen_input_event(fd, monitor_fd);
	
	return 0;
}

