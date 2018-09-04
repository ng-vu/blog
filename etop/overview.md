# Overview

## Timeline

| Date                                 | Note                                                         |
| ------------------------------------ | ------------------------------------------------------------ |
| 5/3/2018<br />Supplier               | - Sync with Kiotviet<br />- Edit products, upload images<br />- Edit price rules, products price<br />- Publish products |
| 11/3/2018<br />Merchant              | - Import products<br />- Edit products<br />- Edit price rules, products price<br />- Sync products with Haravan |
| 21/3/2018<br />Admin                 | - Approve products<br />- Manage eTop categories             |
| 25/3/2018<br />Order management, GHN | - Create orders on eTop<br />- Send to Kiotviet<br />- Send to GHN |

## Supplier

### Price

- Kiotviet
- Wholesale price (giá bán sỉ)
- List price (giá bán lẻ đề nghị)
- Retail price min/max (giá bán lẻ tối thiểu/tối đa)

### Price Rules

```
wholesale_price = a * kiotviet_price + b
```

| variables        | value         | rule                     | example            | note                 |
| ---------------- | ------------- | ------------------------ | ------------------ | -------------------- |
| kiotviet_price   | 1.500.000 VND |                          |                    | Import from Kiotviet |
| list_price       | 1.500.000 VND | = a * kiotviet_price + b | a = 1<br />b = 0   | Supplier defines     |
| wholesale_price  | 750.000 VND   | = a * kiotviet_price + b | a = 0.5<br />b = 0 | Supplier defines     |
| retail_price_min | 1.200.000 VND | = a * list_price + b     | a = ?<br />b = ?   | Supplier defines     |
| retail_price_max | 1.800.000 VND | = a * list_price + b     |                    | Supplier defines     |

## Merchant

### Price Rules

```
retail_price = a * etop_price + b
```

| variables                 | value         | rule                                 | example | note             |
| ------------------------- | ------------- | ------------------------------------ | ------- | ---------------- |
| etop_price                | 900.000 VND   | = wholesale_price + 0.1 * list_price |         | Etop defines     |
| supplier.retail_price_min |               |                                      |         | From supplier    |
| supplier.retail_price_max | 1.800.000 VND |                                      |         | From supplier    |
| retail_price              | 1.600.000 VND |                                      |         | Merchant defines |


## Notes

### Inventory

| variables          | notes                                     |
| ------------------ | ----------------------------------------- |
| quantity_onhand    | From Kiotviet                             |
| quantity_reserved  | From Kiotviet                             |
| quantity_available | = quantity_onhand - quantity_reserved - 3 |

