# Aeson Sum Decoding Example

Test project on how to decode a sum data type with an external discriminator,
while still leveraging the derived/generic `parseJSON` implementation.

## Description

Test on how to "inject" external information to decode a sum data type and
still use the derived/generic `parseJSON` implementation.  

This solution decodes into a `Value`, "injects" the additionally needed
information for the sum type decoding and then parses the result to construct
the expected value.

Other "injection" strategies using different sum encoding options should be easy
to implement in the same way.


## Output

```haskell
RAW: { "A": { "val" : "test" } }
DEC: Just (A {tstVal = "test"})
INJ: Nothing
     Nothing

RAW: { "B": { "val" : "test" } }
DEC: Just (B {tstVal = "test"})
INJ: Nothing
     Nothing

RAW: { "val" : "test" }
DEC: Nothing
INJ: Just (A {tstVal = "test"})
     Just (B {tstVal = "test"})
```
