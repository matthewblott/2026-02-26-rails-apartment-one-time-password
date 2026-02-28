# Project Brief

I have a Rails Todos application with the following features:
- It is multi tenant and the Apartment library is used for this purpose.
- When the user clicks 'sign in' a token is created along with an account. The account is assigned to the device.
- When the user clicks 'sign out' the token is deleted along with their account.

I want to add the following:
- Add one time password functionality (using the rotp library) so an account can be used on more than one device. This should be something existing users opt into and should not be the default.
- Users should have OTP enabled accounts tied to a session and not a device and should be able to have multiple sessions open at the same time on multiple devices.

I have already written the functionality for one time passwords and have tested it successfuly.

I have already written the functionality for a multi tenant Todo application and I have this working successfuly.

The challenge is converting existing device only accounts to session driven accounts.
