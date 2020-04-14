import React from 'react';
import { Container, Row, Col } from 'reactstrap';
import Patcher from './Patcher';

export default function App() {
    return (
        <Container>
            <Row className="justify-content-center mt-3">
                <Col md="8">
                    <Patcher version="0.1" />
                </Col>
            </Row>
        </Container>
    );
}
