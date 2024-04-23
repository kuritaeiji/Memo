# watch

## 結論
watchEffect関数は使用せず、watch関数を使用すべき

## watch 関数

- リアクティブな値・getter 関数・複数ソースを持つ配列を対象にできる
- デフォルトはディープウォッチャー（ネストしたオブジェクトも監視する）、即時実行しないウォッチャー
- オプションとして deep・immediate・once を渡せる

```typescript
const reactiveObj = reactive({
  count: 0
})

const refObj = ref({
  count: 0
})

// 単一のrefとreactiveオブジェクトを対象にできる
// watch関数に渡したcallback関数をsubscriberとして登録する
// reactiveObjの各プロパティーのセッター関数が実行されるとtrigger関数が実行され、subscriberとして登録されたcallback関数を実行する
// subscribers = {
//   reactiveObj: {
//     count: [callback]
//   }
// }
watch(reactiveObj, (newVal, oldVal) => {
  console.log(newVal.count)
})

// refまたはreactiveオブジェクトを含むgetter関数を対象にできる
// getter関数にせずreactive.countをwatchすることはできない（reactive.countは単なるプリミティブな値でリアクティブではないから）
watch(
  () => reactiveObj.count,
  newVal => {
    console.log(newVal)
  },
  { immediate: true }
)

// 複数のソースを含む配列を対象にできる
watch([reactiveObj, () => refObj.value.count], ([newLeft, newRight]) => {
  console.log(newLeft, newRight)
})
```

## watchEffect 関数

watch 関数と違い監視対象を指定する必要がなく、callback 関数内で使用されたリアクティブなオブジェクトを全て自動的に監視する。callback 関数は即時実行される。immediate・deep・once をオプションに指定できない。

```typescript
const reactiveObj = reactive({
  count: 0
})

const refObj = ref({
  count: 0
})

watchEffect(() => {
  console.log(reactiveObj.count, refObj.value.count)
})
```

## 実行タイミング

callback 関数は親コンポーネントの実際の DOM 更新後・自コンポーネントの実際の DOM 更新前に実行される。flush オプションを指定すると実行タイミングを指定可能。

```vue
<script setup lang="ts">
const state = ref({ count: 0 })
const countEl = ref<HtmlDivElement | null>(null)

const unwatchHandlers: WatchStopHandle[] = []

onMounted(() => {
  // 自コンポーネントの実際のDOM更新前にコールバック関数が実行されるのでcountが+1される前の値を取得する。
  unwatchHandlers.push(
    watch(state.value, () => {
      console.log(countEl!.value?.innerText)
    })
  )

  // 自コンポーネントの実際のDOM更新後にコールバック関数が実行されるのでcountが+1された後の値を取得する。
  unwatchHandlers.push(
    watch(
      state.value,
      () => {
        console.log(countEl!.value?.innerText)
      },
      { flush: 'post' }
    )
  )

  // リアクティブな値が更新されるときに更新される。全てのコンポーネントの実際のDOM更新前に実行されるため+1される前の値を取得する。なるべく使用しない。
  unwatchHandlers.push(
    watch(
      state.value,
      () => {
        console.log(countEl!.value?.innerText)
      },
      { flush: 'sync' }
    )
  )
})

onUnmounted(() => {
  unwatchHandlers.forEach(unwatch => unwatch())
})
</script>

<template>
  <div ref="countEl">{{ state.count }}</div>
  <button @click="() => state.count++">1増やす</button>
</template>
```

## ウォッチャーの停止

非同期に watch 関数が登録された場合はアンマウント時に watcher が削除されないため自分で差除する必要がある。

```typescript
const state = reactive({ count: 0 })
let unwatchHandler: WatchStopHandle | undefined

setTimeout(() => {
  unwatchHandler = watch(state, () => {
    console.log(state)
  })
}, 100)

onUnmounted(() => unwatchHandler!())
```
