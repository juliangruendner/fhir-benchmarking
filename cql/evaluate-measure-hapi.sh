#!/usr/bin/env bash

# Usage: ./evaluate-measure.sh -f <query>.cql <server-base>

# Takes a CQL file, creates a Library resource from it, references that from a
# Measure resource and calls $evaluate-measure on it.

library() {
cat <<END
{
  "resourceType": "Library",
  "status": "active",
  "type" : {
    "coding" : [
      {
        "system": "http://terminology.hl7.org/CodeSystem/library-type",
        "code" : "logic-library"
      }
    ]
  },
  "content": [
    {
      "contentType": "text/cql"
    }
  ]
}
END
}

measure() {
cat <<END
{
  "resourceType": "Measure",
  "status": "active",
  "subjectCodeableConcept": {
    "coding": [
      {
        "system": "http://hl7.org/fhir/resource-types",
        "code": "Patient"
      }
    ]
  },
  "scoring": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/measure-scoring",
        "code": "cohort"
      }
    ]
  },
  "group": [
    {
      "population": [
        {
          "code": {
            "coding": [
              {
                "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                "code": "initial-population"
              }
            ]
          },
          "criteria": {
            "language": "text/cql",
            "expression": "InInitialPopulation"
          }
        }
      ]
    }
  ]
}
END
}

fhir-helpers(){
  cat <<END
{
      "id":"FHIRHelpers",
      "name":"FHIRHelpers",
      "version":"4.0.0",
      "resourceType": "Library",
      "status": "active",
      "type" : {
        "coding" : [
          {
            "system": "http://terminology.hl7.org/CodeSystem/library-type",
            "code" : "logic-library"
          }
        ]
      },
      "content": [
        {
          "contentType": "text/cql",
          "data":"bGlicmFyeSBGSElSSGVscGVycyB2ZXJzaW9uICc0LjAuMCcKCnVzaW5nIEZISVIgdmVyc2lvbiAnNC4wLjAnCgpkZWZpbmUgZnVuY3Rpb24gVG9JbnRlcnZhbChwZXJpb2QgRkhJUi5QZXJpb2QpOgogICAgaWYgcGVyaW9kIGlzIG51bGwgdGhlbgogICAgICAgIG51bGwKICAgIGVsc2UKICAgICAgICBpZiBwZXJpb2QuInN0YXJ0IiBpcyBudWxsIHRoZW4KICAgICAgICAgICAgSW50ZXJ2YWwocGVyaW9kLiJzdGFydCIudmFsdWUsIHBlcmlvZC4iZW5kIi52YWx1ZV0KICAgICAgICBlbHNlCiAgICAgICAgICAgIEludGVydmFsW3BlcmlvZC4ic3RhcnQiLnZhbHVlLCBwZXJpb2QuImVuZCIudmFsdWVdCgpkZWZpbmUgZnVuY3Rpb24gVG9DYWxlbmRhclVuaXQodW5pdCBTeXN0ZW0uU3RyaW5nKToKICAgIGNhc2UgdW5pdAogICAgICAgIHdoZW4gJ21zJyB0aGVuICdtaWxsaXNlY29uZCcKICAgICAgICB3aGVuICdzJyB0aGVuICdzZWNvbmQnCiAgICAgICAgd2hlbiAnbWluJyB0aGVuICdtaW51dGUnCiAgICAgICAgd2hlbiAnaCcgdGhlbiAnaG91cicKICAgICAgICB3aGVuICdkJyB0aGVuICdkYXknCiAgICAgICAgd2hlbiAnd2snIHRoZW4gJ3dlZWsnCiAgICAgICAgd2hlbiAnbW8nIHRoZW4gJ21vbnRoJwogICAgICAgIHdoZW4gJ2EnIHRoZW4gJ3llYXInCiAgICAgICAgZWxzZSB1bml0CiAgICBlbmQKCmRlZmluZSBmdW5jdGlvbiBUb1F1YW50aXR5KHF1YW50aXR5IEZISVIuUXVhbnRpdHkpOgogICAgY2FzZQogICAgICAgIHdoZW4gcXVhbnRpdHkgaXMgbnVsbCB0aGVuIG51bGwKICAgICAgICB3aGVuIHF1YW50aXR5LnZhbHVlIGlzIG51bGwgdGhlbiBudWxsCiAgICAgICAgd2hlbiBxdWFudGl0eS5jb21wYXJhdG9yIGlzIG5vdCBudWxsIHRoZW4KICAgICAgICAgICAgTWVzc2FnZShudWxsLCB0cnVlLCAnRkhJUkhlbHBlcnMuVG9RdWFudGl0eS5Db21wYXJhdG9yUXVhbnRpdHlOb3RTdXBwb3J0ZWQnLCAnRXJyb3InLCAnRkhJUiBRdWFudGl0eSB2YWx1ZSBoYXMgYSBjb21wYXJhdG9yIGFuZCBjYW5ub3QgYmUgY29udmVydGVkIHRvIGEgU3lzdGVtLlF1YW50aXR5IHZhbHVlLicpCiAgICAgICAgd2hlbiBxdWFudGl0eS5zeXN0ZW0gaXMgbnVsbCBvciBxdWFudGl0eS5zeXN0ZW0udmFsdWUgPSAnaHR0cDovL3VuaXRzb2ZtZWFzdXJlLm9yZycKICAgICAgICAgICAgICBvciBxdWFudGl0eS5zeXN0ZW0udmFsdWUgPSAnaHR0cDovL2hsNy5vcmcvZmhpcnBhdGgvQ29kZVN5c3RlbS9jYWxlbmRhci11bml0cycgdGhlbgogICAgICAgICAgICBTeXN0ZW0uUXVhbnRpdHkgeyB2YWx1ZTogcXVhbnRpdHkudmFsdWUudmFsdWUsIHVuaXQ6IFRvQ2FsZW5kYXJVbml0KENvYWxlc2NlKHF1YW50aXR5LmNvZGUudmFsdWUsIHF1YW50aXR5LnVuaXQudmFsdWUsICcxJykpIH0KICAgICAgICBlbHNlCiAgICAgICAgICAgIE1lc3NhZ2UobnVsbCwgdHJ1ZSwgJ0ZISVJIZWxwZXJzLlRvUXVhbnRpdHkuSW52YWxpZEZISVJRdWFudGl0eScsICdFcnJvcicsICdJbnZhbGlkIEZISVIgUXVhbnRpdHkgY29kZTogJyAmIHF1YW50aXR5LnVuaXQudmFsdWUgJiAnICgnICYgcXVhbnRpdHkuc3lzdGVtLnZhbHVlICYgJ3wnICYgcXVhbnRpdHkuY29kZS52YWx1ZSAmICcpJykKICAgIGVuZAoKZGVmaW5lIGZ1bmN0aW9uIFRvUXVhbnRpdHlJZ25vcmluZ0NvbXBhcmF0b3IocXVhbnRpdHkgRkhJUi5RdWFudGl0eSk6CiAgICBjYXNlCiAgICAgICAgd2hlbiBxdWFudGl0eSBpcyBudWxsIHRoZW4gbnVsbAogICAgICAgIHdoZW4gcXVhbnRpdHkudmFsdWUgaXMgbnVsbCB0aGVuIG51bGwKICAgICAgICB3aGVuIHF1YW50aXR5LnN5c3RlbSBpcyBudWxsIG9yIHF1YW50aXR5LnN5c3RlbS52YWx1ZSA9ICdodHRwOi8vdW5pdHNvZm1lYXN1cmUub3JnJwogICAgICAgICAgICAgIG9yIHF1YW50aXR5LnN5c3RlbS52YWx1ZSA9ICdodHRwOi8vaGw3Lm9yZy9maGlycGF0aC9Db2RlU3lzdGVtL2NhbGVuZGFyLXVuaXRzJyB0aGVuCiAgICAgICAgICAgIFN5c3RlbS5RdWFudGl0eSB7IHZhbHVlOiBxdWFudGl0eS52YWx1ZS52YWx1ZSwgdW5pdDogVG9DYWxlbmRhclVuaXQoQ29hbGVzY2UocXVhbnRpdHkuY29kZS52YWx1ZSwgcXVhbnRpdHkudW5pdC52YWx1ZSwgJzEnKSkgfQogICAgICAgIGVsc2UKICAgICAgICAgICAgTWVzc2FnZShudWxsLCB0cnVlLCAnRkhJUkhlbHBlcnMuVG9RdWFudGl0eS5JbnZhbGlkRkhJUlF1YW50aXR5JywgJ0Vycm9yJywgJ0ludmFsaWQgRkhJUiBRdWFudGl0eSBjb2RlOiAnICYgcXVhbnRpdHkudW5pdC52YWx1ZSAmICcgKCcgJiBxdWFudGl0eS5zeXN0ZW0udmFsdWUgJiAnfCcgJiBxdWFudGl0eS5jb2RlLnZhbHVlICYgJyknKQogICAgZW5kCgpkZWZpbmUgZnVuY3Rpb24gVG9JbnRlcnZhbChxdWFudGl0eSBGSElSLlF1YW50aXR5KToKICAgIGlmIHF1YW50aXR5IGlzIG51bGwgdGhlbiBudWxsIGVsc2UKICAgICAgICBjYXNlIHF1YW50aXR5LmNvbXBhcmF0b3IudmFsdWUKICAgICAgICAgICAgd2hlbiAnPCcgdGhlbgogICAgICAgICAgICAgICAgSW50ZXJ2YWxbCiAgICAgICAgICAgICAgICAgICAgbnVsbCwKICAgICAgICAgICAgICAgICAgICBUb1F1YW50aXR5SWdub3JpbmdDb21wYXJhdG9yKHF1YW50aXR5KQogICAgICAgICAgICAgICAgKQogICAgICAgICAgICB3aGVuICc8PScgdGhlbgogICAgICAgICAgICAgICAgSW50ZXJ2YWxbCiAgICAgICAgICAgICAgICAgICAgbnVsbCwKICAgICAgICAgICAgICAgICAgICBUb1F1YW50aXR5SWdub3JpbmdDb21wYXJhdG9yKHF1YW50aXR5KQogICAgICAgICAgICAgICAgXQogICAgICAgICAgICB3aGVuICc+PScgdGhlbgogICAgICAgICAgICAgICAgSW50ZXJ2YWxbCiAgICAgICAgICAgICAgICAgICAgVG9RdWFudGl0eUlnbm9yaW5nQ29tcGFyYXRvcihxdWFudGl0eSksCiAgICAgICAgICAgICAgICAgICAgbnVsbAogICAgICAgICAgICAgICAgXQogICAgICAgICAgICB3aGVuICc+JyB0aGVuCiAgICAgICAgICAgICAgICBJbnRlcnZhbCgKICAgICAgICAgICAgICAgICAgICBUb1F1YW50aXR5SWdub3JpbmdDb21wYXJhdG9yKHF1YW50aXR5KSwKICAgICAgICAgICAgICAgICAgICBudWxsCiAgICAgICAgICAgICAgICBdCiAgICAgICAgICAgIGVsc2UKICAgICAgICAgICAgICAgIEludGVydmFsW1RvUXVhbnRpdHkocXVhbnRpdHkpLCBUb1F1YW50aXR5KHF1YW50aXR5KV0KICAgICAgICBlbmQKCmRlZmluZSBmdW5jdGlvbiBUb1JhdGlvKHJhdGlvIEZISVIuUmF0aW8pOgogICAgaWYgcmF0aW8gaXMgbnVsbCB0aGVuCiAgICAgICAgbnVsbAogICAgZWxzZQogICAgICAgIFN5c3RlbS5SYXRpbyB7IG51bWVyYXRvcjogVG9RdWFudGl0eShyYXRpby5udW1lcmF0b3IpLCBkZW5vbWluYXRvcjogVG9RdWFudGl0eShyYXRpby5kZW5vbWluYXRvcikgfQoKZGVmaW5lIGZ1bmN0aW9uIFRvSW50ZXJ2YWwocmFuZ2UgRkhJUi5SYW5nZSk6CiAgICBpZiByYW5nZSBpcyBudWxsIHRoZW4KICAgICAgICBudWxsCiAgICBlbHNlCiAgICAgICAgSW50ZXJ2YWxbVG9RdWFudGl0eShyYW5nZS5sb3cpLCBUb1F1YW50aXR5KHJhbmdlLmhpZ2gpXQoKZGVmaW5lIGZ1bmN0aW9uIFRvQ29kZShjb2RpbmcgRkhJUi5Db2RpbmcpOgogICAgaWYgY29kaW5nIGlzIG51bGwgdGhlbgogICAgICAgIG51bGwKICAgIGVsc2UKICAgICAgICBTeXN0ZW0uQ29kZSB7CiAgICAgICAgICBjb2RlOiBjb2RpbmcuY29kZS52YWx1ZSwKICAgICAgICAgIHN5c3RlbTogY29kaW5nLnN5c3RlbS52YWx1ZSwKICAgICAgICAgIHZlcnNpb246IGNvZGluZy52ZXJzaW9uLnZhbHVlLAogICAgICAgICAgZGlzcGxheTogY29kaW5nLmRpc3BsYXkudmFsdWUKICAgICAgICB9CgpkZWZpbmUgZnVuY3Rpb24gVG9Db25jZXB0KGNvbmNlcHQgRkhJUi5Db2RlYWJsZUNvbmNlcHQpOgogICAgaWYgY29uY2VwdCBpcyBudWxsIHRoZW4KICAgICAgICBudWxsCiAgICBlbHNlCiAgICAgICAgU3lzdGVtLkNvbmNlcHQgewogICAgICAgICAgICBjb2RlczogY29uY2VwdC5jb2RpbmcgQyByZXR1cm4gVG9Db2RlKEMpLAogICAgICAgICAgICBkaXNwbGF5OiBjb25jZXB0LnRleHQudmFsdWUKICAgICAgICB9CgpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi51dWlkKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuVGVzdFNjcmlwdFJlcXVlc3RNZXRob2RDb2RlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuU29ydERpcmVjdGlvbik6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkJpb2xvZ2ljYWxseURlcml2ZWRQcm9kdWN0U3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuVW5pdHNPZlRpbWUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5BZGRyZXNzVHlwZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkFsbGVyZ3lJbnRvbGVyYW5jZUNhdGVnb3J5KTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuSXNzdWVTZXZlcml0eSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkNhcmVUZWFtU3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRW5jb3VudGVyU3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuU3RydWN0dXJlRGVmaW5pdGlvbktpbmQpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5QdWJsaWNhdGlvblN0YXR1cyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkZISVJWZXJzaW9uKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQ2FyZVBsYW5BY3Rpdml0eUtpbmQpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5TdHJ1Y3R1cmVNYXBTb3VyY2VMaXN0TW9kZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlJlcXVlc3RTdGF0dXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5zdHJhbmRUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuUXVlc3Rpb25uYWlyZVJlc3BvbnNlU3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuU2VhcmNoQ29tcGFyYXRvcik6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkNoYXJnZUl0ZW1TdGF0dXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5BY3Rpb25QYXJ0aWNpcGFudFR5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5BbGxlcmd5SW50b2xlcmFuY2VUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQ2FyZVBsYW5BY3Rpdml0eVN0YXR1cyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkludm9pY2VTdGF0dXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5DbGFpbVByb2Nlc3NpbmdDb2Rlcyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlJlcXVlc3RSZXNvdXJjZVR5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5QYXJ0aWNpcGF0aW9uU3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRGV2aWNlTmFtZVR5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Eb2N1bWVudE1vZGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Bc3NlcnRpb25PcGVyYXRvclR5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5EYXlzT2ZXZWVrKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuSXNzdWVUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuY2Fub25pY2FsKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuU3RydWN0dXJlTWFwQ29udGV4dFR5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5GYW1pbHlIaXN0b3J5U3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuc3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRXh0ZW5zaW9uQ29udGV4dFR5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Bc3NlcnRpb25SZXNwb25zZVR5cGVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuUmVxdWVzdEludGVudCk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLnN0cmluZyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkFjdGlvblJlcXVpcmVkQmVoYXZpb3IpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5HcmFwaENvbXBhcnRtZW50VXNlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIub3JpZW50YXRpb25UeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQWNjb3VudFN0YXR1cyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLklkZW50aWZpZXJVc2UpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5TdHJ1Y3R1cmVNYXBUYXJnZXRMaXN0TW9kZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkV4cG9zdXJlU3RhdGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5UZXN0UmVwb3J0UGFydGljaXBhbnRUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQmluZGluZ1N0cmVuZ3RoKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuUmVxdWVzdFByaW9yaXR5KTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuUGFydGljaXBhbnRSZXF1aXJlZCk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlhQYXRoVXNhZ2VUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuaWQpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5GaWx0ZXJPcGVyYXRvcik6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLk5hbWluZ1N5c3RlbVR5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Db250cmFjdFJlc291cmNlU3RhdHVzQ29kZXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5SZXNlYXJjaFN1YmplY3RTdGF0dXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5TdHJ1Y3R1cmVNYXBUcmFuc2Zvcm0pOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5SZXNwb25zZVR5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9EZWNpbWFsKHZhbHVlIEZISVIuZGVjaW1hbCk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkFnZ3JlZ2F0aW9uTW9kZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLnNlcXVlbmNlVHlwZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlN5c3RlbVJlc3RmdWxJbnRlcmFjdGlvbik6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkFkdmVyc2VFdmVudEFjdHVhbGl0eSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlN1YnNjcmlwdGlvbkNoYW5uZWxUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQXNzZXJ0aW9uRGlyZWN0aW9uVHlwZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkNhcmVQbGFuSW50ZW50KTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQWxsZXJneUludG9sZXJhbmNlQ3JpdGljYWxpdHkpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Qcm9wZXJ0eVJlcHJlc2VudGF0aW9uKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuVHJpZ2dlclR5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Db21wb3NpdGlvblN0YXR1cyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkFwcG9pbnRtZW50U3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuTWVzc2FnZVNpZ25pZmljYW5jZUNhdGVnb3J5KTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuTGlzdE1vZGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5SZXNlYXJjaEVsZW1lbnRUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuT2JzZXJ2YXRpb25TdGF0dXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5SZXNvdXJjZVR5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9Cb29sZWFuKHZhbHVlIEZISVIuYm9vbGVhbik6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlN0cnVjdHVyZU1hcEdyb3VwVHlwZU1vZGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5TdXBwbHlSZXF1ZXN0U3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRW5jb3VudGVyTG9jYXRpb25TdGF0dXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Db25kaXRpb25hbERlbGV0ZVN0YXR1cyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLnVybCk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLnVyaSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlVzZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLk1lZGljYXRpb25SZXF1ZXN0U3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuSWRlbnRpdHlBc3N1cmFuY2VMZXZlbCk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkRldmljZU1ldHJpY0NvbG9yKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvVGltZSh2YWx1ZSBGSElSLnRpbWUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Db25kaXRpb25hbFJlYWRTdGF0dXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5BbGxlcmd5SW50b2xlcmFuY2VTZXZlcml0eSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkZpbmFuY2lhbFJlc291cmNlU3RhdHVzQ29kZXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5PcGVyYXRpb25LaW5kKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuU3Vic2NyaXB0aW9uU3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuR29hbExpZmVjeWNsZVN0YXR1cyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLk9ic2VydmF0aW9uRGF0YVR5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Eb2N1bWVudFJlZmVyZW5jZVN0YXR1cyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLnJlcG9zaXRvcnlUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuTG9jYXRpb25TdGF0dXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Ob3RlVHlwZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlRlc3RSZXBvcnRTdGF0dXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Db2RlU3lzdGVtQ29udGVudE1vZGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5GSElSRGV2aWNlU3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQ29udGFjdFBvaW50U3lzdGVtKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuU2xvdFN0YXR1cyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlByb3BlcnR5VHlwZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlR5cGVEZXJpdmF0aW9uUnVsZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkd1aWRhbmNlUmVzcG9uc2VTdGF0dXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5SZWxhdGVkQXJ0aWZhY3RUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIub2lkKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQ29tcGFydG1lbnRUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuTWVkaWNhdGlvblJlcXVlc3RJbnRlbnQpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5JbnZvaWNlUHJpY2VDb21wb25lbnRUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRGV2aWNlTWV0cmljQ2FsaWJyYXRpb25TdGF0ZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkdyb3VwVHlwZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkVuYWJsZVdoZW5CZWhhdmlvcik6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlRhc2tJbnRlbnQpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5JbW11bml6YXRpb25FdmFsdWF0aW9uU3RhdHVzQ29kZXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5FeGFtcGxlU2NlbmFyaW9BY3RvclR5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Qcm92ZW5hbmNlRW50aXR5Um9sZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlNwZWNpbWVuU3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuUmVzdGZ1bENhcGFiaWxpdHlNb2RlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRGV0ZWN0ZWRJc3N1ZVNldmVyaXR5KTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuVmlzaW9uRXllcyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkNvbnNlbnREYXRhTWVhbmluZyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLm1lc3NhZ2VoZWFkZXJSZXNwb25zZVJlcXVlc3QpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5HdWlkZVBhZ2VHZW5lcmF0aW9uKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRG9jdW1lbnRSZWxhdGlvbnNoaXBUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuVmFyaWFibGVUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuVGVzdFJlcG9ydFJlc3VsdCk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkNvbmNlcHRNYXBHcm91cFVubWFwcGVkTW9kZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb0RhdGVUaW1lKHZhbHVlIEZISVIuaW5zdGFudCk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb0RhdGVUaW1lKHZhbHVlIEZISVIuZGF0ZVRpbWUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9EYXRlKHZhbHVlIEZISVIuZGF0ZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb0ludGVnZXIodmFsdWUgRkhJUi5wb3NpdGl2ZUludCk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkNsaW5pY2FsSW1wcmVzc2lvblN0YXR1cyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkVsaWdpYmlsaXR5UmVzcG9uc2VQdXJwb3NlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuTmFycmF0aXZlU3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuSW1hZ2luZ1N0dWR5U3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRW5kcG9pbnRTdGF0dXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5CaW9sb2dpY2FsbHlEZXJpdmVkUHJvZHVjdENhdGVnb3J5KTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuUmVzb3VyY2VWZXJzaW9uUG9saWN5KTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQWN0aW9uQ2FyZGluYWxpdHlCZWhhdmlvcik6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkdyb3VwTWVhc3VyZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLk5hbWluZ1N5c3RlbUlkZW50aWZpZXJUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuSW1tdW5pemF0aW9uU3RhdHVzQ29kZXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5NZWRpY2F0aW9uU3RhdHVzQ29kZXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5EaXNjcmltaW5hdG9yVHlwZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlN0cnVjdHVyZU1hcElucHV0TW9kZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkxpbmthZ2VUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuUmVmZXJlbmNlSGFuZGxpbmdQb2xpY3kpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5SZXNlYXJjaFN0dWR5U3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQXVkaXRFdmVudE91dGNvbWUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5TcGVjaW1lbkNvbnRhaW5lZFByZWZlcmVuY2UpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5BY3Rpb25SZWxhdGlvbnNoaXBUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQ29uc3RyYWludFNldmVyaXR5KTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRXZlbnRDYXBhYmlsaXR5TW9kZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkNvZGVTZWFyY2hTdXBwb3J0KTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuT2JzZXJ2YXRpb25SYW5nZUNhdGVnb3J5KTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuVURJRW50cnlUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRGV2aWNlTWV0cmljQ2F0ZWdvcnkpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5UZXN0UmVwb3J0QWN0aW9uUmVzdWx0KTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQ2FwYWJpbGl0eVN0YXRlbWVudEtpbmQpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5FdmVudFRpbWluZyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlNlYXJjaFBhcmFtVHlwZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkFjdGlvbkdyb3VwaW5nQmVoYXZpb3IpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5TdHJ1Y3R1cmVNYXBNb2RlbE1vZGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5UYXNrU3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQmlvbG9naWNhbGx5RGVyaXZlZFByb2R1Y3RTdG9yYWdlU2NhbGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5HcmFwaENvbXBhcnRtZW50UnVsZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlNsaWNpbmdSdWxlcyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkV4cGxhbmF0aW9uT2ZCZW5lZml0U3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuR3VpZGVQYXJhbWV0ZXJDb2RlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQ2F0YWxvZ0VudHJ5UmVsYXRpb25UeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuTGlua1R5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Db25jZXB0TWFwRXF1aXZhbGVuY2UpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5BdWRpdEV2ZW50QWN0aW9uKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuU2VhcmNoTW9kaWZpZXJDb2RlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRXZlbnRTdGF0dXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5PcGVyYXRpb25QYXJhbWV0ZXJVc2UpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Db25zZW50UHJvdmlzaW9uVHlwZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkFjdGlvbkNvbmRpdGlvbktpbmQpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5xdWFsaXR5VHlwZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkFkbWluaXN0cmF0aXZlR2VuZGVyKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuUXVlc3Rpb25uYWlyZUl0ZW1UeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRGV2aWNlTWV0cmljQ2FsaWJyYXRpb25UeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRXZpZGVuY2VWYXJpYWJsZVR5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5jb2RlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQWN0aW9uU2VsZWN0aW9uQmVoYXZpb3IpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5TdXBwbHlEZWxpdmVyeVN0YXR1cyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkRpYWdub3N0aWNSZXBvcnRTdGF0dXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5GbGFnU3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuU1BEWExpY2Vuc2UpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5MaXN0U3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuYmFzZTY0QmluYXJ5KTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRGV2aWNlVXNlU3RhdGVtZW50U3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQXVkaXRFdmVudEFnZW50TmV0d29ya1R5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5FeHByZXNzaW9uTGFuZ3VhZ2UpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5BZGRyZXNzVXNlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQ29udGFjdFBvaW50VXNlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRGV2aWNlTWV0cmljT3BlcmF0aW9uYWxTdGF0dXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Db250cmlidXRvclR5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5SZWZlcmVuY2VWZXJzaW9uUnVsZXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5NZWFzdXJlUmVwb3J0U3RhdHVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuU2VhcmNoRW50cnlNb2RlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvSW50ZWdlcih2YWx1ZSBGSElSLnVuc2lnbmVkSW50KTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuTmFtZVVzZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkxvY2F0aW9uTW9kZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb0ludGVnZXIodmFsdWUgRkhJUi5pbnRlZ2VyKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRkhJUlN1YnN0YW5jZVN0YXR1cyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlF1ZXN0aW9ubmFpcmVJdGVtT3BlcmF0b3IpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5IVFRQVmVyYik6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkVwaXNvZGVPZkNhcmVTdGF0dXMpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5SZW1pdHRhbmNlT3V0Y29tZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLm1hcmtkb3duKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuRWxpZ2liaWxpdHlSZXF1ZXN0UHVycG9zZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlF1YW50aXR5Q29tcGFyYXRvcik6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLk1lYXN1cmVSZXBvcnRUeXBlKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuQWN0aW9uUHJlY2hlY2tCZWhhdmlvcik6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlNhbXBsZWREYXRhRGF0YVR5cGUpOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Db21wb3NpdGlvbkF0dGVzdGF0aW9uTW9kZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLlR5cGVSZXN0ZnVsSW50ZXJhY3Rpb24pOiB2YWx1ZS52YWx1ZQpkZWZpbmUgZnVuY3Rpb24gVG9TdHJpbmcodmFsdWUgRkhJUi5Db2RlU3lzdGVtSGllcmFyY2h5TWVhbmluZyk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLnZDb25maWRlbnRpYWxpdHlDbGFzc2lmaWNhdGlvbik6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkNvbnRyYWN0UmVzb3VyY2VQdWJsaWNhdGlvblN0YXR1c0NvZGVzKTogdmFsdWUudmFsdWUKZGVmaW5lIGZ1bmN0aW9uIFRvU3RyaW5nKHZhbHVlIEZISVIuVmlzaW9uQmFzZSk6IHZhbHVlLnZhbHVlCmRlZmluZSBmdW5jdGlvbiBUb1N0cmluZyh2YWx1ZSBGSElSLkJ1bmRsZVR5cGUpOiB2YWx1ZS52YWx1ZQo="
        }
      ]

}
END
}


create-library() {
  library | jq -cM ".url = \"urn:uuid:$1\" | .name = \"$1\" | .content[0].data = \"$2\""
}

create-measure() {
  measure | jq -cM ".url = \"urn:uuid:$1\" | .library[0] = \"Library/$2\" | .subjectCodeableConcept.coding[0].code = \"$3\""
}

post() {
  curl -sH "Content-Type: application/fhir+json" -d @- "${BASE}/$1"
}
put() {
  curl -sX PUT -H "Content-Type: application/fhir+json" -d @- "${BASE}/$1"
}

evaluate-measure() {
  time curl -s "${BASE}/Measure/$1/\$evaluate-measure?periodStart=2000&periodEnd=2019"
}

usage()
{
  echo "Usage: $0 -f QUERY_FILE [ -t type ] BASE"
  exit 2
}

unset FILE TYPE BASE

while getopts 'f:t:' c
do
  case ${c} in
    f) FILE=$OPTARG ;;
    t) TYPE=$OPTARG ;;
  esac
done

shift $((OPTIND-1))
BASE=$1

[[ -z "$FILE" ]] && usage
[[ -z "$TYPE" ]] && TYPE="Patient"
[[ -z "$BASE" ]] && usage

DATA=$(cat ${FILE} | base64 | tr -d '\n')
LIBRARY_URI=$(uuidgen | tr '[:upper:]' '[:lower:]')
MEASURE_URI=$(uuidgen | tr '[:upper:]' '[:lower:]')

FHIRHelpers_ID=$(fhir-helpers | put "Library/FHIRHelpers")

LIBRARY_ID=$(create-library ${LIBRARY_URI} ${DATA} | post "Library" | jq -r .id)

MEASURE_ID=$(create-measure ${MEASURE_URI} ${LIBRARY_ID} ${TYPE} | post "Measure" | jq -r .id)

echo "Evaluate measure ${MEASURE_ID} ..."
COUNT=$(evaluate-measure ${MEASURE_ID} | jq ".group[0].population[0].count")

printf "Count: ${COUNT} \n\n\n"