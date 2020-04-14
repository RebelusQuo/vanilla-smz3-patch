import { inflate } from 'pako';

export async function readAsArrayBuffer(blob) {
    const fileReader = new FileReader();
    return new Promise((resolve, reject) => {
        fileReader.onerror = () => {
            fileReader.abort();
            reject(new DOMException('Error parsing data'));
        };

        fileReader.onload = (e) => {
            resolve(e.target.result);
        };

        fileReader.readAsArrayBuffer(blob);
    });
}

export function maybeInflate(data) {
    const isGzip = dw_be_value(data, 0) === 0x1f8b;
    return isGzip ? inflate(data) : data;
}

export function dw_be_value(bytes, i = 0) {
    return (bytes[i] << 8) | bytes[i+1];
}

export function dd_le_value(bytes, i = 0) {
    return (bytes[i+3] << 24) | (bytes[i+2] << 16) | (bytes[i+1] << 8) | bytes[i];
}
