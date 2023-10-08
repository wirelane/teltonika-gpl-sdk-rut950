#include <assert.h>
#include <stdio.h>
#include <libusb-1.0/libusb.h>

#define FEATURE_PORT_RESET 4
#define USB_SERIAL_TIMEOUT 1000

#define CY_DEVICE_RESET_CMD 0xE3
#define CY_VENDOR_REQUEST_DEVICE_TO_HOST 0xC0

#define FTDI_DEVICE_OUT_REQTYPE	(LIBUSB_REQUEST_TYPE_VENDOR | \
                                 LIBUSB_RECIPIENT_DEVICE | \
                                 LIBUSB_ENDPOINT_OUT)
#define SIO_RESET_SIO   0
#define SIO_RESET_REQUEST   0

int main()
{
	libusb_context *context = NULL;
	libusb_device_handle *dev_handle = NULL;
	int rc = 0;
	int port;

	rc = libusb_init(&context);
	assert(rc == 0);

	// ----------------- USB SERIAL RESET -------------------------------------------
	dev_handle = libusb_open_device_with_vid_pid(context, 0x0403, 0x6001); // FT232RL
	if(dev_handle) {
		libusb_set_auto_detach_kernel_driver(dev_handle, 1);
		libusb_claim_interface(dev_handle, 0);

		rc = libusb_control_transfer (dev_handle,
				FTDI_DEVICE_OUT_REQTYPE,
				SIO_RESET_REQUEST,
				SIO_RESET_SIO, 0, NULL, 0,
				USB_SERIAL_TIMEOUT);
		if(rc < 0)
			printf("USB RESET: FTDI result %s \n", port, libusb_error_name(rc));

		goto hub_rst;
	}

	dev_handle = libusb_open_device_with_vid_pid(context, 0x04b4, 0x0003); // CY7C65213
	if(dev_handle) {
		libusb_set_auto_detach_kernel_driver(dev_handle, 1);
		libusb_claim_interface(dev_handle, 0);

		rc = libusb_control_transfer (dev_handle,
				CY_VENDOR_REQUEST_DEVICE_TO_HOST,
				CY_DEVICE_RESET_CMD,
				0xA6B6, 0xADBA, NULL, 0, USB_SERIAL_TIMEOUT);

		if(rc < 0)
			printf("USB RESET: CYPRESS result %s \n", port, libusb_error_name(rc));

	}

hub_rst:
	// ------------------ HUB RESET---------------------------------------------------
	dev_handle = libusb_open_device_with_vid_pid(context, 0x05e3, 0x0610); // GL852
	if(!dev_handle)
		dev_handle = libusb_open_device_with_vid_pid(context, 0x0424, 0x2513); // USB2513B
	if(!dev_handle) {
		printf("USB RESET: usb hub not detected! \n");
		libusb_exit(context);
		return(1);
	}
	libusb_set_auto_detach_kernel_driver(dev_handle, 1);
	libusb_claim_interface(dev_handle, 0);

	for (port = 1; port < 5; port++)
	{
		rc = libusb_control_transfer(dev_handle,
				LIBUSB_REQUEST_TYPE_CLASS | LIBUSB_RECIPIENT_OTHER,
				LIBUSB_REQUEST_SET_FEATURE,
				FEATURE_PORT_RESET, port, NULL, 0, USB_SERIAL_TIMEOUT);
		if(rc < 0)
			printf("USB RESET: transfer set %d result %s \n", port, libusb_error_name(rc));
	}

	libusb_close(dev_handle);
	libusb_exit(context);

	printf("USB RESET: finish ... \n");

	return(0);
}
