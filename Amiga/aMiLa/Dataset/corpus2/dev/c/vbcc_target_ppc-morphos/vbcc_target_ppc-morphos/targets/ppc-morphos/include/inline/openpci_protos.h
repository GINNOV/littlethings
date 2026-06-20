#ifndef _VBCCINLINE_OPENPCI_H
#define _VBCCINLINE_OPENPCI_H

#ifndef EXEC_TYPES_H
#include <exec/types.h>
#endif
#ifndef EMUL_EMULREGS_H
#include <emul/emulregs.h>
#endif

unsigned short __pci_bus(void *) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tli\t3,-30\n"
	"\tbctrl";
#define pci_bus() __pci_bus(OpenPciBase)

unsigned char __pci_inb(void *, unsigned long address) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-36\n"
	"\tbctrl";
#define pci_inb(address) __pci_inb(OpenPciBase, (address))

void __pci_outb(void *, unsigned char value, unsigned long address) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-42\n"
	"\tbctrl";
#define pci_outb(value, address) __pci_outb(OpenPciBase, (value), (address))

unsigned short __pci_inw(void *, unsigned long address) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-48\n"
	"\tbctrl";
#define pci_inw(address) __pci_inw(OpenPciBase, (address))

void __pci_outw(void *, unsigned short value, unsigned long address) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-54\n"
	"\tbctrl";
#define pci_outw(value, address) __pci_outw(OpenPciBase, (value), (address))

unsigned long __pci_inl(void *, unsigned long address) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-60\n"
	"\tbctrl";
#define pci_inl(address) __pci_inl(OpenPciBase, (address))

void __pci_outl(void *, unsigned long value, unsigned long address) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-66\n"
	"\tbctrl";
#define pci_outl(value, address) __pci_outl(OpenPciBase, (value), (address))

void __pci_to_hostcpy(void *, void * pcimemsrc, void * memdest, unsigned long packetsize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-72\n"
	"\tbctrl";
#define pci_to_hostcpy(pcimemsrc, memdest, packetsize) __pci_to_hostcpy(OpenPciBase, (pcimemsrc), (memdest), (packetsize))

void __host_to_pcicpy(void *, void * memsrc, void * pcimemdest, unsigned long packetsize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-78\n"
	"\tbctrl";
#define host_to_pcicpy(memsrc, pcimemdest, packetsize) __host_to_pcicpy(OpenPciBase, (memsrc), (pcimemdest), (packetsize))

void __pci_to_pcicpy(void *, void * pcimemsrc, void * pcimemdest, unsigned long packetsize) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tstw\t6,0(2)\n"
	"\tli\t3,-84\n"
	"\tbctrl";
#define pci_to_pcicpy(pcimemsrc, pcimemdest, packetsize) __pci_to_pcicpy(OpenPciBase, (pcimemsrc), (pcimemdest), (packetsize))

struct  pci_dev * __pci_find_device(void *, unsigned short vendor, unsigned short device, struct pci_dev * pcidev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tli\t3,-90\n"
	"\tbctrl";
#define pci_find_device(vendor, device, pcidev) __pci_find_device(OpenPciBase, (vendor), (device), (pcidev))

struct  pci_dev * __pci_find_class(void *, unsigned long d0arg, struct  pci_dev * pcidev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-96\n"
	"\tbctrl";
#define pci_find_class(d0arg, pcidev) __pci_find_class(OpenPciBase, (d0arg), (pcidev))

struct  pci_dev * __pci_find_slot(void *, unsigned char bus, unsigned long devfn) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-102\n"
	"\tbctrl";
#define pci_find_slot(bus, devfn) __pci_find_slot(OpenPciBase, (bus), (devfn))

unsigned char __pci_read_config_byte(void *, unsigned char registernum, struct  pci_dev * pcidev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-108\n"
	"\tbctrl";
#define pci_read_config_byte(registernum, pcidev) __pci_read_config_byte(OpenPciBase, (registernum), (pcidev))

unsigned short __pci_read_config_word(void *, unsigned char registernum, struct  pci_dev * pcidev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-114\n"
	"\tbctrl";
#define pci_read_config_word(registernum, pcidev) __pci_read_config_word(OpenPciBase, (registernum), (pcidev))

unsigned long __pci_read_config_long(void *, unsigned char registernum, struct  pci_dev * pcidev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,32(2)\n"
	"\tli\t3,-120\n"
	"\tbctrl";
#define pci_read_config_long(registernum, pcidev) __pci_read_config_long(OpenPciBase, (registernum), (pcidev))

void __pci_write_config_byte(void *, unsigned char registernum, unsigned char val, struct  pci_dev * pcidev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tli\t3,-126\n"
	"\tbctrl";
#define pci_write_config_byte(registernum, val, pcidev) __pci_write_config_byte(OpenPciBase, (registernum), (val), (pcidev))

void __pci_write_config_word(void *, unsigned char registernum, unsigned short val, struct  pci_dev * pcidev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tli\t3,-132\n"
	"\tbctrl";
#define pci_write_config_word(registernum, val, pcidev) __pci_write_config_word(OpenPciBase, (registernum), (val), (pcidev))

void __pci_write_config_long(void *, unsigned char registernum, unsigned long val, struct  pci_dev * pcidev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tstw\t6,32(2)\n"
	"\tli\t3,-138\n"
	"\tbctrl";
#define pci_write_config_long(registernum, val, pcidev) __pci_write_config_long(OpenPciBase, (registernum), (val), (pcidev))

BOOL __pci_set_master(void *, struct  pci_dev * pcidev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tli\t3,-144\n"
	"\tbctrl";
#define pci_set_master(pcidev) __pci_set_master(OpenPciBase, (pcidev))

BOOL __pci_add_intserver(void *, struct Interrupt * PciInterrupt, struct pci_dev * pcidev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-150\n"
	"\tbctrl";
#define pci_add_intserver(PciInterrupt, pcidev) __pci_add_intserver(OpenPciBase, (PciInterrupt), (pcidev))

void __pci_rem_intserver(void *, struct Interrupt * PciInterrupt, struct pci_dev * pcidev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-156\n"
	"\tbctrl";
#define pci_rem_intserver(PciInterrupt, pcidev) __pci_rem_intserver(OpenPciBase, (PciInterrupt), (pcidev))

APTR __pci_allocdma_mem(void *, unsigned long size, unsigned long flags) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,0(2)\n"
	"\tstw\t5,4(2)\n"
	"\tli\t3,-162\n"
	"\tbctrl";
#define pci_allocdma_mem(size, flags) __pci_allocdma_mem(OpenPciBase, (size), (flags))

void __pci_freedma_mem(void *, APTR buffer, unsigned long size) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,0(2)\n"
	"\tli\t3,-168\n"
	"\tbctrl";
#define pci_freedma_mem(buffer, size) __pci_freedma_mem(OpenPciBase, (buffer), (size))

APTR __pci_logic_to_physic_addr(void *, APTR PciLogicalAddr, struct pci_dev * pcidev) =
	"\tlwz\t11,100(2)\n"
	"\tstw\t3,56(2)\n"
	"\tmtctr\t11\n"
	"\tstw\t4,32(2)\n"
	"\tstw\t5,36(2)\n"
	"\tli\t3,-174\n"
	"\tbctrl";
#define pci_logic_to_physic_addr(PciLogicalAddr, pcidev) __pci_logic_to_physic_addr(OpenPciBase, (PciLogicalAddr), (pcidev))

#endif /*  _VBCCINLINE_OPENPCI_H  */
