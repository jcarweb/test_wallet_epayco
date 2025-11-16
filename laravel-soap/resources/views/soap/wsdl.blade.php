<?xml version="1.0" encoding="UTF-8"?>
<definitions xmlns="http://schemas.xmlsoap.org/wsdl/"
             xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/"
             xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/"
             xmlns:tns="{{ url('/soap') }}"
             targetNamespace="{{ url('/soap') }}">

    <types>
        <schema xmlns="http://www.w3.org/2001/XMLSchema" targetNamespace="{{ url('/soap') }}">
            <element name="registerClientRequest">
                <complexType>
                    <sequence>
                        <element name="document" type="string"/>
                        <element name="fullName" type="string"/>
                        <element name="email" type="string"/>
                        <element name="phoneNumber" type="string"/>
                    </sequence>
                </complexType>
            </element>
            <element name="registerClientResponse">
                <complexType>
                    <sequence>
                        <element name="success" type="boolean"/>
                        <element name="cod_error" type="string"/>
                        <element name="message_error" type="string"/>
                        <element name="data" type="anyType"/>
                    </sequence>
                </complexType>
            </element>

            <element name="rechargeWalletRequest">
                <complexType>
                    <sequence>
                        <element name="document" type="string"/>
                        <element name="phoneNumber" type="string"/>
                        <element name="amount" type="float"/>
                    </sequence>
                </complexType>
            </element>
            <element name="rechargeWalletResponse">
                <complexType>
                    <sequence>
                        <element name="success" type="boolean"/>
                        <element name="cod_error" type="string"/>
                        <element name="message_error" type="string"/>
                        <element name="data" type="anyType"/>
                    </sequence>
                </complexType>
            </element>

            <element name="initiatePaymentRequest">
                <complexType>
                    <sequence>
                        <element name="document" type="string"/>
                        <element name="phoneNumber" type="string"/>
                        <element name="amount" type="float"/>
                    </sequence>
                </complexType>
            </element>
            <element name="initiatePaymentResponse">
                <complexType>
                    <sequence>
                        <element name="success" type="boolean"/>
                        <element name="cod_error" type="string"/>
                        <element name="message_error" type="string"/>
                        <element name="data" type="anyType"/>
                    </sequence>
                </complexType>
            </element>

            <element name="confirmPaymentRequest">
                <complexType>
                    <sequence>
                        <element name="sessionId" type="string"/>
                        <element name="token" type="string"/>
                    </sequence>
                </complexType>
            </element>
            <element name="confirmPaymentResponse">
                <complexType>
                    <sequence>
                        <element name="success" type="boolean"/>
                        <element name="cod_error" type="string"/>
                        <element name="message_error" type="string"/>
                        <element name="data" type="anyType"/>
                    </sequence>
                </complexType>
            </element>

            <element name="checkBalanceRequest">
                <complexType>
                    <sequence>
                        <element name="document" type="string"/>
                        <element name="phoneNumber" type="string"/>
                    </sequence>
                </complexType>
            </element>
            <element name="checkBalanceResponse">
                <complexType>
                    <sequence>
                        <element name="success" type="boolean"/>
                        <element name="cod_error" type="string"/>
                        <element name="message_error" type="string"/>
                        <element name="data" type="anyType"/>
                    </sequence>
                </complexType>
            </element>
        </schema>
    </types>

    <message name="registerClientRequest">
        <part name="parameters" element="tns:registerClientRequest"/>
    </message>
    <message name="registerClientResponse">
        <part name="parameters" element="tns:registerClientResponse"/>
    </message>

    <message name="rechargeWalletRequest">
        <part name="parameters" element="tns:rechargeWalletRequest"/>
    </message>
    <message name="rechargeWalletResponse">
        <part name="parameters" element="tns:rechargeWalletResponse"/>
    </message>

    <message name="initiatePaymentRequest">
        <part name="parameters" element="tns:initiatePaymentRequest"/>
    </message>
    <message name="initiatePaymentResponse">
        <part name="parameters" element="tns:initiatePaymentResponse"/>
    </message>

    <message name="confirmPaymentRequest">
        <part name="parameters" element="tns:confirmPaymentRequest"/>
    </message>
    <message name="confirmPaymentResponse">
        <part name="parameters" element="tns:confirmPaymentResponse"/>
    </message>

    <message name="checkBalanceRequest">
        <part name="parameters" element="tns:checkBalanceRequest"/>
    </message>
    <message name="checkBalanceResponse">
        <part name="parameters" element="tns:checkBalanceResponse"/>
    </message>

    <portType name="WalletServicePortType">
        <operation name="registerClient">
            <input message="tns:registerClientRequest"/>
            <output message="tns:registerClientResponse"/>
        </operation>
        <operation name="rechargeWallet">
            <input message="tns:rechargeWalletRequest"/>
            <output message="tns:rechargeWalletResponse"/>
        </operation>
        <operation name="initiatePayment">
            <input message="tns:initiatePaymentRequest"/>
            <output message="tns:initiatePaymentResponse"/>
        </operation>
        <operation name="confirmPayment">
            <input message="tns:confirmPaymentRequest"/>
            <output message="tns:confirmPaymentResponse"/>
        </operation>
        <operation name="checkBalance">
            <input message="tns:checkBalanceRequest"/>
            <output message="tns:checkBalanceResponse"/>
        </operation>
    </portType>

    <binding name="WalletServiceBinding" type="tns:WalletServicePortType">
        <soap12:binding style="document" transport="http://schemas.xmlsoap.org/soap/http"/>
        <operation name="registerClient">
            <soap12:operation soapAction="{{ url('/soap') }}/registerClient" soapActionRequired="false"/>
            <input>
                <soap12:body use="literal"/>
            </input>
            <output>
                <soap12:body use="literal"/>
            </output>
        </operation>
        <operation name="rechargeWallet">
            <soap12:operation soapAction="{{ url('/soap') }}/rechargeWallet" soapActionRequired="false"/>
            <input>
                <soap12:body use="literal"/>
            </input>
            <output>
                <soap12:body use="literal"/>
            </output>
        </operation>
        <operation name="initiatePayment">
            <soap12:operation soapAction="{{ url('/soap') }}/initiatePayment" soapActionRequired="false"/>
            <input>
                <soap12:body use="literal"/>
            </input>
            <output>
                <soap12:body use="literal"/>
            </output>
        </operation>
        <operation name="confirmPayment">
            <soap12:operation soapAction="{{ url('/soap') }}/confirmPayment" soapActionRequired="false"/>
            <input>
                <soap12:body use="literal"/>
            </input>
            <output>
                <soap12:body use="literal"/>
            </output>
        </operation>
        <operation name="checkBalance">
            <soap12:operation soapAction="{{ url('/soap') }}/checkBalance" soapActionRequired="false"/>
            <input>
                <soap12:body use="literal"/>
            </input>
            <output>
                <soap12:body use="literal"/>
            </output>
        </operation>
    </binding>

    <service name="WalletService">
        <port name="WalletServicePort" binding="tns:WalletServiceBinding">
            <soap12:address location="{{ url('/soap/service') }}"/>
        </port>
    </service>
</definitions>

