const { accounts, contract } = require('@openzeppelin/test-environment');
const { expect } = require('chai');

const Rift = contract.fromArtifact('Rift'); // Loads a compiled contract

const TEST_CRYSTAL = 'data:application/json;base64,eyJuYW1lIjogIlNoZWV0ICMAAAAAAAAAAAAAAAD7b2hLGfONbQ5pqj5pRdi6Qd1oACIsICJkZXNjcmlwdGlvbiI6ICJBYmlsaXR5IFNjb3JlcyBhcmUgcmFuZG9taXplZCB0YWJsZSB0b3AgUlBHIHN0eWxlIHN0YXRzIGdlbmVyYXRlZCBhbmQgc3RvcmVkIG9uIGNoYWluLiBGZWVsIGZyZWUgdG8gdXNlIEFiaWxpdHkgU2NvcmVzIGluIGFueSB3YXkgeW91IHdhbnQuIiwgImltYWdlIjogImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjRiV3h1Y3owaWFIUjBjRG92TDNkM2R5NTNNeTV2Y21jdk1qQXdNQzl6ZG1jaUlIQnlaWE5sY25abFFYTndaV04wVW1GMGFXODlJbmhOYVc1WlRXbHVJRzFsWlhRaUlIWnBaWGRDYjNnOUlqQWdNQ0F6TlRBZ016VXdJajQ4YzNSNWJHVStMbUpoYzJVZ2V5Qm1hV3hzT2lCM2FHbDBaVHNnWm05dWRDMW1ZVzFwYkhrNklITmxjbWxtT3lCbWIyNTBMWE5wZW1VNklERTBjSGc3SUgwOEwzTjBlV3hsUGp4eVpXTjBJSGRwWkhSb1BTSXhNREFsSWlCb1pXbG5hSFE5SWpFd01DVWlJR1pwYkd3OUltSnNZV05ySWlBdlBqeDBaWGgwSUhnOUlqRXdJaUI1UFNJeU1DSWdZMnhoYzNNOUltSmhjMlVpUGsxaGJtRWdRM0o1YzNSaGJEd3ZkR1Y0ZEQ0OEwzUmxlSFErUEM5emRtYysifQ==';

describe('Rift', () => {
    it('should return crystal by wallet', async () => {
        const riftInstance = await Rift.new();
        // Get by first address
        const storedData = await riftInstance.tokenURI(accounts[0]);
        expect(storedData).to.be.equal(TEST_CRYSTAL);
    });
});
