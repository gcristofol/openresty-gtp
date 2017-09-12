import hmac
import hashlib
import base64

digest_maker = hmac.new('key', digestmod=hashlib.sha256)
digest_maker.update('foo')

digest = digest_maker.hexdigest()
print len(digest)
print digest
