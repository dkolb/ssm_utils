# SSM Utilities

[![Build Status](https://travis-ci.org/dkolb/ssm_utils.svg?branch=master)](https://travis-ci.org/dkolb/ssm_utils)
[![Gem Version](https://badge.fury.io/rb/ssm_utils.svg)](https://badge.fury.io/rb/ssm_utils)

## Introduction
The intended workflow is to use `manage_ssm_params get` to retrieve a subtree
of your account's SSM Parameter Store to a YAML file.  You then update or add
to the YAML file what you want to change.

That said, the YAML emitting is kinda bad, especially for very large parameters
like SSH keys and the like.

## Usage: `manage_ssm_params`

Both the commands `put` and `get` operate with the idea that a set of SSM
parameters can be represented as a nested hash.  Paths are split on the `/`
delimiter such that the parameter `/TestApp/uat/DBHost` with a value of
`db.example.com` and a type of `String` can be represented as

```yaml
---
TestApp:
  uat:
    DBHost: db.example.com
```

SSM parameters of the type `SecureString` have a more comlex "value" in the
YAML that is emitted and consumed by the CLI tool.

```yaml
---
TestApp:
  uat:
    DBPassword:
      _value: some-password
      _type: SecureString
      _key: alias/my_key_alias
```

Note that `_key` can also be a full KMS key ARN.  These values are retrieved
by calling the SSM API's `GetParameterHistory`.  If it was put with a KMS
alias, the history will show the alias.  Similarly, if it was put with a key
arn, then the API will return the arn.

`StringList`s, the only other supported type by AWS as of this writing, is
similarly declared.

```yaml
---
TestApp:
  uat:
    AllowedRoles:
      _value: Admin,PowerUser
      _type: StringList
```

Non-sring values in YAML, such as numbers and booleans, will have their
`to_s` representation passed to SSM.  Similarly, using an `Array` or `Hash` may
not work the way you intend it to from Ruby version to Ruby version.

### `get`

```
  NAME:

    get

  SYNOPSIS:

    manage_ssm_params get [OPTIONS]

  DESCRIPTION:

    Retrieves an entire tree of your SSM parameter store as a well
    structured YAML document.

  OPTIONS:

    --file FILE
        File to retrieve account to.

    --[no-]decrypt
        Decrypt SecureStrings, default true

    --ssm_root PATH_ROOT
        A path root to retrieve from, default is '/'
```

### `put`
```
  NAME:

    put

  SYNOPSIS:

    manage_ssm_params put [OPTIONS]

  DESCRIPTION:

    Writes the supplied YAML structure into SSM parameter store using
    the reverse of the mappings used by get.


  OPTIONS:

    --file FILE
        File to retrieve account to.

    --retry-limit INTEGER
        increase retry limit, default 3

    --[no-]overwrite
        Overwrite exitings strings, default true
```

Note that overwriting and putting are naieve.  They will blindly write values
to the API whether they have changed or not.


## Development

Please do all development on the `dev` branch.  PRs are accepted.  Please try
to have specs written for what you are fixing or adding.

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.


Use `bundle rake install` to install the gem locally.

## Other Similar Projects

A Python project similar to this one is
[`ssm-diff`](https://github.com/runtheops/ssm-diff).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/dkolb/ssm_utils

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).  AKA steal it, IGAF.
