# Available enpoints

## Settings

> GET extended_api/settings
<details>

```bash
curl <redmine-host>/extended_api/settings
```

</details>

> POST extended_api/settings

<details>
    <summary>Example</summary>

```bash
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"settings": { "app_title": "MegaRedmine" } }' \
  <redmine-host>/extended_api/settings
```

</details>