1. # Notes

   ## Supplier

   ### Thay đổi giá sản phẩm:

   1. Supplier thay đổi giá.
   2. Chọn thời gian muốn cập nhật giá chính thức.
   3. Ngừng bán sản phẩm.
   4. Status thay đổi trạng thái về “chờ duyệt”
   5. Admin duyệt.
   6. Apply theo ngày supplier chọn.

   #### Rủi ro

   Admin duyệt trễ hơn thời gian Supplier chọn » apply ngay » Chờ sau 12h đêm cập nhật.

   Policy thay đổi giá không cần admin duyệt (Duyệt tự động):

   1. Tăng chiết khấu cho eTop <=10%.
   2. Thay đổi giá bán lẻ TĂNG hoặc GIẢM trong khoảng 20%. Điều kiện chiết khấu KHÔNG GIẢM hoặc tăng <=10% như (1)

   ## Đơn hàng (Order)

   1. Đơn hàng được đồng bộ từ Haravan
   2. Haravan có thể huỷ đơn hàng (khách, shop)
   3. Shop xác nhận hoặc huỷ đơn hàng
   4. Supplier có thể huỷ đơn hàng
   5. GHN có thể huỷ đơn hàng

   ## Đơn vận chuyển (Fulfillment)

   ### Shop xác nhận đơn hàng để tạo đơn vận chuyển

   **Một đơn hàng sẽ được tạo thành nhiều đơn vận chuyển.**

   1. Một đơn vận chuyển bao gồm nhiều sản phẩm từ cùng một supplier.
   2. Mỗi supplier chỉ tạo một đơn vận chuyển.
   3. Nếu đơn hàng có sản phẩm từ shop, sẽ tương ứng với một đơn vận chuyển cho shop.

   **Ví dụ**

   | Line | Variant | Supplier | Shop | Fulfillment |
   | ---- | ------- | -------- | ---- | ----------- |
   | 1    | 1001    | 100      |      | F1          |
   | 2    | 1002    | 100      |      | F1          |
   | 3    | 1011    | 101      |      | F2          |
   | 4    | 2001    |          | 200  | F3          |

   **Nguồn đơn hàng**

   | Nguồn đơn hàng                            | Source       | Ràng buộc                                                    |
   | ----------------------------------------- | ------------ | ------------------------------------------------------------ |
   | Khách mua từ Haravan                      | `haravan`    | - Khách hàng đặt mua sản phẩm từ Haravan<br />- Đơn có thể gồm sản phẩm etop và sản phẩm của shop<br />Địa chỉ nhận hàng được lấy từ Haravan, shop có thể chỉnh sửa |
   | Shop tự bán cho khách từ **pos**, **pxs** | `pos`, `pxs` | - Shop tạo đơn hàng từ **pos**, **pxs**<br />- Đơn có thể gồm sản phẩm của etop và sản phẩm của shop<br />- Địa chỉ nhận hàng là của khách |
   | Shop mua hàng từ supplier                 | `self`       | - Shop đặt mua từ **pos**<br />- Đơn chỉ gồm sản phẩm từ supplier<br />- Địa chỉ nhận hàng là shop |

   **Nguồn sản phẩm**

   | Nguồn sản phẩm    | Ràng buộc                                                    |
   | ----------------- | ------------------------------------------------------------ |
   | Sản phẩm etop     | - Sản phẩm từ một supplier cụ thể<br />- Địa chỉ gửi hàng do supplier cung cấp trong *settings* |
   | Sản phẩm của shop | - Sản phẩm từ shop<br />- Địa chỉ gửi hàng do shop cung cấp trong *settings* hoặc khi tạo đơn hàng |

   **Phân loại**

   ```js
   switch {
   case source == 'self' && product.source.type == 'supplier':
       fulfillment.address_from = supplier.ship_from_address
       fulfillment.address_to   =    order.shipping_address || shop.ship_to_address
       fulfillment.shipping_fee_customer = 0        // không quản lý
       fulfillment.shipping_fee_shop     = {{'free' || '30k'}}
       fulfillment.shipping_fee_etop     = {{returned from giaohangnhanh}}
       break;
   
   case source != 'self' && product.source.type == 'supplier':
       fulfillment.address_from = supplier.ship_from_address
       fulfillment.address_to   = order.shipping_address
       fulfillment.shipping_fee_customer = {{shop input}}
       fulfillment.shipping_fee_shop     = {{'free' || '30k'}}
       fulfillment.shipping_fee_etop     = {{returned from giaohangnhanh}}
       break;
   
   case source != 'self' && product.source.type == 'shop':
       fulfillment.address_from =  shop.ship_from_address
       fulfillment.address_to   = order.shipping_address
       fulfillment.shipping_fee_customer = {{shop input}}
       fulfillment.shipping_fee_shop     = {{returned from giaohangnhanh - discount for etop}}
       fulfillment.shipping_fee_etop     = {{returned from giaohangnhanh}}
       break;  
   
   default:
   	{{ error }}
   }
   ```

   **Lỗi**

   | Lỗi                                                          | Ghi chú                                                      | Xử lý                                                        |
   | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
   | Đơn hàng đã *huỷ*/*hoàn thành*.                              | Đơn đã bị huỷ hoặc đã giao thành công. <br />1. `order.status: P/N`<br />2. `order.confirm_status: N`<br />3. `order.shop_confirm: N` |                                                              |
   | Nhập hàng: Chỉ được bao gồm sản phẩm có nguồn từ eTop.       | `source: self` và có sản phẩm không phải etop.               | Shop huỷ đơn, tạo mới.                                       |
   | Thông tin địa chỉ nhà cung cấp.                              | `supplier.ship_from_address_id: null/invalid`                | Supplier thêm thông tin địa chỉ vào *settings*.              |
   | Thông tin địa chỉ người nhận.                                | `order.shipping_address: null/invalid`<br />Lưu ý chỉ sử dụng `shipping_address`, không sử dụng các address khác như `billing_address` hay `customer_address`. | Shop sửa đơn hàng.                                           |
   | Thông tin địa chỉ cửa hàng trong đơn hàng.                   | `order.shop_address: invalid`                                | Shop sửa đơn hàng.                                           |
   | Thông tin địa chỉ cửa hàng trong cấu hình cửa hàng.          | `shop.ship_from_address_id: null`                            | Shop thêm/sửa thông tin địa chỉ trong *settings*.            |
   | Bán hàng: Cần cung cấp thông tin địa chỉ lấy hàng trong đơn hàng hoặc tại thông tin cửa hàng. | `order.shop_address: null` && `shop.ship_from_address_id: null` | Shop thêm/sửa thông tin địa chỉ trong ** hoặc *order*.       |
   | (nhà cung cấp/người nhận/...)<br />Thiếu thông tin địa chỉ.  |                                                              | (supplier/shop) Thêm thông tin địa chỉ.                      |
   | (nhà cung cấp/người nhận/...)<br />Địa chỉ ... không thể được xác định bởi hệ thống. | `address.ward_code: null/invalid`                            | (supplier/shop) Sửa địa chỉ hợp lệ.                          |
   | (nhà cung cấp/người nhận/...)<br />Địa chỉ ... không thể được giao bởi dịch vụ vận chuyển. | Quận/huyện không tồn tại trong hệ thống của GHN.             | (supplier/shop) Sửa địa chỉ hợp lệ.<br />Hoặc etop kiểm tra. |
