const std = @import("std");

pub const Ehdr = extern struct {
    ident: [16]u8,
    type: u16,
    machine: u16,
    version: u32,
    entry: u64,
    ph_off: u64,
    sh_off: u64,
    flags: u32,
    eh_size: u16,
    ph_ent_size: u16,
    ph_num: u16,
    sh_ent_size: u16,
    sh_num: u16,
    sh_strndx: u16,
};

pub const Shdr = extern struct {
    name: u32,
    type: u32,
    flags: u64,
    addr: u64,
    offset: u64,
    size: u64,
    link: u32,
    info: u32,
    addr_align: u64,
    ent_size: u64,
};

pub const EhdrSize: usize = @sizeOf(Ehdr);
pub const ShdrSize: usize = @sizeOf(Shdr);
