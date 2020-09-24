# Security policy

## Supported versions

Only the most recent stable version is supported.

## Reporting a vulnerability

Please report any security issues via email to security@getontracks.org.
If you don't get a reply for your email, resend the email after one week.
If there's still no reply, open an issue in the issue queue but *do not
disclose the details* in the issue, only ask about the reply and status.

You can (and should) encrypt the email you send with OpenGPG key
0x8af45b6854414d2d, which you can find for example in pool.sks-keyservers.net.

Unfortunately Tracks is not part of a bug bounty program, but we do provide
appropriate credits for disclosing security issues.

## Evaluating and fixing a vulnerability

When a security vulnerability is reported to the maintainers, the
maintainers first validate the vulnerability and preliminarily estimate
the risk caused by the vulnerability.

Any security issue is kept strictly confidential until a fix is made and
validated by the maintainers and, if necessary, the reporter. Any fixes
are not committed to the public repository before publishing.

When a fix has been validated, the final risk assessment of the issue is
done based on the latest version of the CVSS system and the criteria below.

## Security advisories

A security advisory is a public announcement managed by the maintainers
which informs instance maintainers about a security problem in the software
and the steps instance maintainers should take to address it. On release it
is published widely so that instance maintainers can address it quickly.

If necessary, the maintainers can decide to issue a pre-announcement
informing the instance maintainers of an upcoming security advisory. This
is done when timely addressing of the vulnerability is very important due
to the high risk caused by it.

Security advisories are published for security vulnerabilities that

* Are caused by code included in the software repository (not any libraries
  or other code not itself in the repository),
* Exist in stable or release candidate releases (not alpha or beta
  releases or unreleased code),
* Are exploitable either without logging in or without admin privileges, and
* Affect either the whole instance or other users than the one running the
  exploit.

## Other vulnerabilities

If the vulnerability does not warrant a security advisory, the vulnerability
is fixed and released with a note in the release notes of the release.
Details of the vulnerability as well as the risk assessment and grounds for
not publishing a security advisory are included.
