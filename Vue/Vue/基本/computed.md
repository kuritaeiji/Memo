# computed

## computed を使用する理由

```typescript
const book = ref({ title: '本', author: '著者' })
const bookTitleComputed = computed(() => book.value.title)
const bookTitleMethod = () => book.value.title
```

computed を使用せず通常のメソッドを使用しても同じ結果になる。ただし computed は依存しているリアクティブな値が更新された場合のみ再評価されるが、メソッドは依存していないリアクティブな値が更新された場合も再評価されてしまう。よって computed を使用すべき。

## computed の仕組み

```typescript
type computed<T> = (getter: () => T) => Readonly<Ref<Readonly<T>>>

// track関数を実行した際にsubscriberとして登録する関数の配列
const activeSubscribers: (() => void)[] = []

const subscribers = {}

const computed = getter => {
  // getter関数をactiveSubscribers配列に追加する
  activeSubscribers.push(getter)
  // getter関数を実行することでgetter関数内で使用されたリアクティブな値のゲッター関数を呼び出しtrack関数を実行しsubscribersとしてgetter関数を登録する（activeSubscribersにgetter関数が追加されているためsubscribersにgetter関数が登録される）
  const result = getter()
  return ref(result)
}

const ref<T> = (target: T): Ref<T> => ({
  value: target,
  get value() {
    track(target, 'value')
    return this.value
  },
  set value(newValue) {
    this.value = newValue
    trigger(newValue, 'value')
  }
})

const track = (object: object, key: string) => {
  // activeSubscribersをsubscriber関数として登録する
  subscribers[object][key].push(activeSubscribers)
  activeSubscribers = []
}
```
