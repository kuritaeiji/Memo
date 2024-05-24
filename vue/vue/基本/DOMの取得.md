# DOM の取得

## 単一の DOM

ref オブジェクトを使用して DOM を取得可能。ref オブジェクトの変数名と HTML の ref 属性名を同じにする。

```vue
<script setup lang="ts">
const inputEl = ref<HTMLInputElement | null>(null)
</script>

<template>
  <input ref="inputEl" />
</template>
```

## v-for の複数の DOM

ref オブジェクトを使用して v-for で作成した複数の DOM を配列として取得可能。ref オブジェクトの変数名と HTML の ref 属性名を同じにする。

```vue
<script setup lang="ts">
const listEls = ref<HTMLElement[]>([])
</script>

<template>
  <li
    v-for="n in [1, 2, 3]"
    :key="n"
    ref="listEls"
  >
    {{ n }}
  </li>
</template>
```
