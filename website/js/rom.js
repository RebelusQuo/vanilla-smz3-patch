import { h32 } from 'xxhashjs';

import { readAsArrayBuffer, maybeInflate, dd_le_value } from './util';

// "SMZ3" as UTF8 in big-endian
const HashSeed = 0x534D5A33;
const Hash = {
    z3: 0x8AC8FD15,
    sm: 0xCADB4883,
};

export function checkData(data, name) {
    data = stripHeader(data);
    return h32(data.buffer, HashSeed).toNumber() === Hash[name];
}

function stripHeader(data) {
    return data.length % 0x1000 === 0x200 ? data.slice(0x200) : data;
}

export async function patchComboRom(patch, rom) {
    rom = mergeIntoComboRom({
        sm: new Uint8Array(await readAsArrayBuffer(rom.sm)),
        z3: new Uint8Array(await readAsArrayBuffer(rom.z3))
    });

    patch = await readAsArrayBuffer(patch);
    patch = maybeInflate(new Uint8Array(patch));

    applyBin(rom, patch);

    return new Blob([rom]);
}

function mergeIntoComboRom({ sm, z3 }) {
    const rom = new Uint8Array(0x600000);

    let offset = 0;
    for (let i = 0; i < 0x40; i++) {
        const hiBank = sm.slice((i * 0x8000), (i * 0x8000) + 0x8000);
        const loBank = sm.slice(((i + 0x40) * 0x8000), ((i + 0x40) * 0x8000) + 0x8000);

        rom.set(loBank, offset);
        rom.set(hiBank, offset + 0x8000);
        offset += 0x10000;
    }

    offset = 0x400000;
    for (let i = 0; i < 0x20; i++) {
        const hiBank = z3.slice((i * 0x8000), (i * 0x8000) + 0x8000);
        rom.set(hiBank, offset + 0x8000);
        offset += 0x10000;
    }

    return rom;
}

function applyBin(rom, patch) {
    let offset = 0;
    while (offset < patch.length) {
        const dest = dd_le_value(patch, offset);
        const length = dd_le_value(patch, offset + 4);
        offset += 8;
        rom.set(patch.slice(offset, offset + length), dest);
        offset += length;
    }
}
