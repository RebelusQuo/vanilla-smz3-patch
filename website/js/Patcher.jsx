import React, { useState, useEffect } from 'react';
import { Card, CardHeader, CardBody, Button } from 'reactstrap';
import { Modal, ModalHeader, ModalBody, Progress } from 'reactstrap';
import Upload from './Upload';

import { saveAs } from 'file-saver';
import localforage from 'localforage';

import attempt from 'lodash/attempt';

import { patchComboRom } from './rom';

import vanillaPatch from '../resources/vanilla-zsm.bin.gz';

export default function Patcher(props) {
    const { version } = props;

    const [romsProvided, setRomsProvided] = useState(false);
    const [showModal, setShowshowModal] = useState(false);

    useEffect(() => {
        attempt(async () => {
            const sm = await localforage.getItem('baseRomSM');
            const z3 = await localforage.getItem('baseRomZ3');
            setRomsProvided(z3 !== null && sm !== null);
        });
    }, []);

    function onUploadRoms() {
        setRomsProvided(true);
    }

    async function onDownloadRom() {
        try {
            const patch = await (await fetch(vanillaPatch, { cache: 'no-store' })).blob();
            const rom = await patchComboRom(patch, {
                sm: await localforage.getItem('baseRomSM'),
                z3: await localforage.getItem('baseRomZ3'),
            });
            saveAs(rom, `vanilla-smz3-v${version}.sfc`);
        } catch (error) {
            console.log(error);
        }
    }

    return <>
        {romsProvided
            ? <Card>
                <CardHeader className="bg-primary text-white">Download vanilla combo ROM file - Version {version}</CardHeader>
                <CardBody>
                    <Button color="primary" onClick={onDownloadRom}>Download</Button>
                </CardBody>
            </Card>
            : <Card>
                <CardHeader className="bg-primary text-white">Provide source ROM files</CardHeader>
                <CardBody>
                    <Upload onUpload={onUploadRoms} />
                </CardBody>
            </Card>
        }
        <Modal isOpen={showModal} backdrop="static" autoFocus>
            <ModalHeader>Constructing ROM file</ModalHeader>
            <ModalBody>
                <p>Please wait while the vanilla combo ROM is being constructed.</p>
                <Progress animated color="info" value={100} />
            </ModalBody>
        </Modal>
    </>;
}