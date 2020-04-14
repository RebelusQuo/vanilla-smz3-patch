import React, { useState, useRef } from 'react';
import { Row, Col, Form, Button } from 'reactstrap';

import localforage from 'localforage';

import some from 'lodash/some';
import map from 'lodash/map';
import compact from 'lodash/compact';
import hasIn from 'lodash/hasIn';

import { checkData } from './rom';
import { readAsArrayBuffer } from './util';

export default function Upload(props) {
    const { onUpload } = props;

    const [canUpload, setCanUpload] = useState(false);
    const fileInputZ3 = useRef(null);
    const fileInputSM = useRef(null);

    async function onSubmitRom() {
        const z3File = fileInputZ3.current.files[0];
        const smFile = fileInputSM.current.files[0];

        let fileDataZ3 = null;
        let fileDataSM = null;
        const mismatch = {};

        try {
            fileDataZ3 = new Uint8Array(await readAsArrayBuffer(z3File));
            mismatch.ALttP = !checkData(fileDataZ3, 'z3');
        } catch (error) {
            console.log("Could not read uploaded ALttP file data:", error);
            return;
        }

        try {
            fileDataSM = new Uint8Array(await readAsArrayBuffer(smFile));
            mismatch.SM = !checkData(fileDataSM, 'sm');
        } catch (error) {
            console.log("Could not read uploaded SM file data:", error);
            return;
        }

        if (some(mismatch)) {
            const files = compact(map(mismatch, (truth, name) => truth ? name : null));
            alert(`Incorrect ${files.join(', ')} ROM file(s)`);
            return;
        }

        try {
            await localforage.setItem('baseRomZ3', new Blob([fileDataZ3]));
            await localforage.setItem('baseRomSM', new Blob([fileDataSM]));
        } catch (error) {
            console.log("Could not store file to localforage:", error);
            return;
        }

        onUpload();
    }

    function onFileSelect() {
        setCanUpload(hasIn(fileInputZ3.current, 'files[0]') && hasIn(fileInputSM.current, 'files[0]'));
    }

    return (
        <Form onSubmit={(e) => { e.preventDefault(); onSubmitRom(); }}>
            <Row className="justify-content-between">
                <Col md="6">ALttP ROM: <input type="file" ref={fileInputZ3} onChange={onFileSelect} /></Col>
                <Col md="6">SM ROM: <input type="file" ref={fileInputSM} onChange={onFileSelect} /></Col>
            </Row>
            <Row className="mt-3">
                <Col md="6">
                    <Button type="submit" color="primary" disabled={!canUpload}>Upload Files</Button>
                </Col>
            </Row>
        </Form>
    );
}
