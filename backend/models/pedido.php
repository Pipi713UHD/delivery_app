<?php

require_once __DIR__ . "/../config/conexion.php";

class Pedido
{
    private $conexion;

    public function __construct()
    {
        $db = new Conexion();
        $this->conexion = $db->conectar();
    }

    public function crear($data)
    {
        $this->conexion->begin_transaction();

        try {
            $id_cliente = intval($data["id_cliente"]);
            $id_restaurante = intval($data["id_restaurante"]);
            $id_direccion = intval($data["id_direccion"]);
            $metodo_pago = $data["metodo_pago"] ?? "efectivo";
            $observacion = $data["observacion"] ?? "";
            $productos = $data["productos"];

            $id_estado_pedido = 1; // pendiente
            $descuento = 0;
            $subtotal_pedido = 0;

            // Obtener costo de envío del restaurante
            $sqlEnvio = "SELECT costo_envio FROM restaurantes WHERE id_restaurante = ? LIMIT 1";
            $stmtEnvio = $this->conexion->prepare($sqlEnvio);
            $stmtEnvio->bind_param("i", $id_restaurante);
            $stmtEnvio->execute();
            $resEnvio = $stmtEnvio->get_result();
            $restaurante = $resEnvio->fetch_assoc();

            if (!$restaurante) {
                throw new Exception("Restaurante no encontrado");
            }

            $costo_envio = floatval($restaurante["costo_envio"]);

            $detallePreparado = [];

            foreach ($productos as $item) {
                $id_producto = intval($item["id_producto"]);
                $cantidad = intval($item["cantidad"]);
                $observacion_producto = $item["observacion"] ?? "";
                $extras = $item["extras"] ?? [];

                if ($cantidad <= 0) {
                    throw new Exception("Cantidad inválida");
                }

                // Obtener precio real del producto desde la base de datos
                $sqlProducto = "SELECT id_producto, precio 
                                FROM productos 
                                WHERE id_producto = ? 
                                AND id_restaurante = ?
                                AND estado = 1 
                                AND disponible = 1
                                LIMIT 1";

                $stmtProducto = $this->conexion->prepare($sqlProducto);
                $stmtProducto->bind_param("ii", $id_producto, $id_restaurante);
                $stmtProducto->execute();
                $resProducto = $stmtProducto->get_result();
                $producto = $resProducto->fetch_assoc();

                if (!$producto) {
                    throw new Exception("Producto no disponible");
                }

                $precio_unitario = floatval($producto["precio"]);
                $subtotal_producto = $precio_unitario * $cantidad;

                $extrasPreparados = [];
                $total_extras = 0;

                foreach ($extras as $extraItem) {
                    if (is_array($extraItem)) {
                        $id_extra = intval($extraItem["id_extra"]);
                    } else {
                        $id_extra = intval($extraItem);
                    }

                    $sqlExtra = "SELECT id_extra, precio_extra 
                                 FROM extras_producto 
                                 WHERE id_extra = ? 
                                 AND id_producto = ?
                                 AND estado = 1
                                 LIMIT 1";

                    $stmtExtra = $this->conexion->prepare($sqlExtra);
                    $stmtExtra->bind_param("ii", $id_extra, $id_producto);
                    $stmtExtra->execute();
                    $resExtra = $stmtExtra->get_result();
                    $extra = $resExtra->fetch_assoc();

                    if ($extra) {
                        $precio_extra_total = floatval($extra["precio_extra"]) * $cantidad;
                        $total_extras += $precio_extra_total;

                        $extrasPreparados[] = [
                            "id_extra" => $id_extra,
                            "precio_extra" => $precio_extra_total
                        ];
                    }
                }

                $subtotal_linea = $subtotal_producto + $total_extras;
                $subtotal_pedido += $subtotal_linea;

                $detallePreparado[] = [
                    "id_producto" => $id_producto,
                    "cantidad" => $cantidad,
                    "precio_unitario" => $precio_unitario,
                    "subtotal" => $subtotal_producto,
                    "observacion" => $observacion_producto,
                    "extras" => $extrasPreparados
                ];
            }

            $total = $subtotal_pedido + $costo_envio - $descuento;

            // Insertar pedido
            $sqlPedido = "INSERT INTO pedidos
                (id_cliente, id_restaurante, id_direccion, id_estado_pedido, subtotal, costo_envio, descuento, total, metodo_pago, observacion)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            $stmtPedido = $this->conexion->prepare($sqlPedido);
            $stmtPedido->bind_param(
                "iiiiddddss",
                $id_cliente,
                $id_restaurante,
                $id_direccion,
                $id_estado_pedido,
                $subtotal_pedido,
                $costo_envio,
                $descuento,
                $total,
                $metodo_pago,
                $observacion
            );

            $stmtPedido->execute();
            $id_pedido = $this->conexion->insert_id;

            // Insertar detalle del pedido
            foreach ($detallePreparado as $detalle) {
                $sqlDetalle = "INSERT INTO detalle_pedido
                    (id_pedido, id_producto, cantidad, precio_unitario, subtotal, observacion)
                    VALUES (?, ?, ?, ?, ?, ?)";

                $stmtDetalle = $this->conexion->prepare($sqlDetalle);
                $stmtDetalle->bind_param(
                    "iiidds",
                    $id_pedido,
                    $detalle["id_producto"],
                    $detalle["cantidad"],
                    $detalle["precio_unitario"],
                    $detalle["subtotal"],
                    $detalle["observacion"]
                );

                $stmtDetalle->execute();
                $id_detalle_pedido = $this->conexion->insert_id;

                // Insertar extras del pedido
                foreach ($detalle["extras"] as $extra) {
                    $sqlPedidoExtra = "INSERT INTO pedido_extras
                        (id_detalle_pedido, id_extra, precio_extra)
                        VALUES (?, ?, ?)";

                    $stmtPedidoExtra = $this->conexion->prepare($sqlPedidoExtra);
                    $stmtPedidoExtra->bind_param(
                        "iid",
                        $id_detalle_pedido,
                        $extra["id_extra"],
                        $extra["precio_extra"]
                    );

                    $stmtPedidoExtra->execute();
                }
            }

            // Registrar pago pendiente
            $estado_pago = "pendiente";

            $sqlPago = "INSERT INTO pagos
                (id_pedido, metodo_pago, monto, estado)
                VALUES (?, ?, ?, ?)";

            $stmtPago = $this->conexion->prepare($sqlPago);
            $stmtPago->bind_param(
                "isds",
                $id_pedido,
                $metodo_pago,
                $total,
                $estado_pago
            );

            $stmtPago->execute();

            // Guardar historial
            $comentario = "Pedido creado por el cliente";

            $sqlHistorial = "INSERT INTO historial_pedido
                (id_pedido, id_estado_pedido, comentario)
                VALUES (?, ?, ?)";

            $stmtHistorial = $this->conexion->prepare($sqlHistorial);
            $stmtHistorial->bind_param(
                "iis",
                $id_pedido,
                $id_estado_pedido,
                $comentario
            );

            $stmtHistorial->execute();

            $this->conexion->commit();

            return [
                "id_pedido" => $id_pedido,
                "subtotal" => $subtotal_pedido,
                "costo_envio" => $costo_envio,
                "descuento" => $descuento,
                "total" => $total,
                "estado" => "pendiente"
            ];

        } catch (Exception $e) {
            $this->conexion->rollback();

            return [
                "error" => true,
                "message" => $e->getMessage()
            ];
        }
    }

    public function listarPorCliente($id_cliente)
    {
        $sql = "SELECT 
                    p.id_pedido,
                    r.nombre AS restaurante,
                    ep.nombre AS estado,
                    p.subtotal,
                    p.costo_envio,
                    p.descuento,
                    p.total,
                    p.metodo_pago,
                    p.fecha_pedido
                FROM pedidos p
                INNER JOIN restaurantes r ON p.id_restaurante = r.id_restaurante
                INNER JOIN estados_pedido ep ON p.id_estado_pedido = ep.id_estado_pedido
                WHERE p.id_cliente = ?
                ORDER BY p.fecha_pedido DESC";

        $stmt = $this->conexion->prepare($sql);
        $stmt->bind_param("i", $id_cliente);
        $stmt->execute();

        $resultado = $stmt->get_result();

        $pedidos = [];

        while ($fila = $resultado->fetch_assoc()) {
            $pedidos[] = $fila;
        }

        return $pedidos;
    }

    public function obtenerDetalle($id_pedido)
    {
        $sqlPedido = "SELECT 
                        p.id_pedido,
                        c.id_cliente,
                        r.nombre AS restaurante,
                        ep.nombre AS estado,
                        d.direccion,
                        d.referencia,
                        d.latitud,
                        d.longitud,
                        p.subtotal,
                        p.costo_envio,
                        p.descuento,
                        p.total,
                        p.metodo_pago,
                        p.observacion,
                        p.fecha_pedido
                    FROM pedidos p
                    INNER JOIN clientes c ON p.id_cliente = c.id_cliente
                    INNER JOIN restaurantes r ON p.id_restaurante = r.id_restaurante
                    INNER JOIN direcciones d ON p.id_direccion = d.id_direccion
                    INNER JOIN estados_pedido ep ON p.id_estado_pedido = ep.id_estado_pedido
                    WHERE p.id_pedido = ?
                    LIMIT 1";

        $stmtPedido = $this->conexion->prepare($sqlPedido);
        $stmtPedido->bind_param("i", $id_pedido);
        $stmtPedido->execute();

        $resPedido = $stmtPedido->get_result();
        $pedido = $resPedido->fetch_assoc();

        if (!$pedido) {
            return null;
        }

        $sqlDetalle = "SELECT 
                            dp.id_detalle_pedido,
                            dp.id_producto,
                            pr.nombre AS producto,
                            dp.cantidad,
                            dp.precio_unitario,
                            dp.subtotal,
                            dp.observacion
                        FROM detalle_pedido dp
                        INNER JOIN productos pr ON dp.id_producto = pr.id_producto
                        WHERE dp.id_pedido = ?";

        $stmtDetalle = $this->conexion->prepare($sqlDetalle);
        $stmtDetalle->bind_param("i", $id_pedido);
        $stmtDetalle->execute();

        $resDetalle = $stmtDetalle->get_result();

        $detalles = [];

        while ($detalle = $resDetalle->fetch_assoc()) {
            $id_detalle_pedido = $detalle["id_detalle_pedido"];

            $sqlExtras = "SELECT 
                            pe.id_pedido_extra,
                            ep.nombre AS extra,
                            pe.precio_extra
                          FROM pedido_extras pe
                          INNER JOIN extras_producto ep ON pe.id_extra = ep.id_extra
                          WHERE pe.id_detalle_pedido = ?";

            $stmtExtras = $this->conexion->prepare($sqlExtras);
            $stmtExtras->bind_param("i", $id_detalle_pedido);
            $stmtExtras->execute();

            $resExtras = $stmtExtras->get_result();

            $extras = [];

            while ($extra = $resExtras->fetch_assoc()) {
                $extras[] = $extra;
            }

            $detalle["extras"] = $extras;
            $detalles[] = $detalle;
        }

        $pedido["detalle"] = $detalles;

        return $pedido;
    }

    public function listarDisponiblesRepartidor()
{
    $sql = "SELECT 
                p.id_pedido,
                r.nombre AS restaurante,
                ep.nombre AS estado,
                p.subtotal,
                p.costo_envio,
                p.descuento,
                p.total,
                p.metodo_pago,
                p.fecha_pedido
            FROM pedidos p
            INNER JOIN restaurantes r ON p.id_restaurante = r.id_restaurante
            INNER JOIN estados_pedido ep ON p.id_estado_pedido = ep.id_estado_pedido
            WHERE p.id_repartidor IS NULL
            AND p.id_estado_pedido IN (1, 2, 3, 4)
            ORDER BY p.fecha_pedido DESC";

    $resultado = $this->conexion->query($sql);

    $pedidos = [];

    while ($fila = $resultado->fetch_assoc()) {
        $pedidos[] = $fila;
    }

    return $pedidos;
}

public function aceptarPedidoRepartidor($id_pedido, $id_repartidor)
{
    $this->conexion->begin_transaction();

    try {
        $sqlRepartidor = "SELECT id_repartidor 
                          FROM repartidores 
                          WHERE id_repartidor = ? 
                          AND disponible = 1
                          LIMIT 1";

        $stmtRepartidor = $this->conexion->prepare($sqlRepartidor);
        $stmtRepartidor->bind_param("i", $id_repartidor);
        $stmtRepartidor->execute();

        $resRepartidor = $stmtRepartidor->get_result();

        if ($resRepartidor->num_rows === 0) {
            throw new Exception("Repartidor no disponible o no encontrado");
        }

        $sqlPedido = "SELECT id_pedido, id_repartidor 
                      FROM pedidos 
                      WHERE id_pedido = ?
                      LIMIT 1";

        $stmtPedido = $this->conexion->prepare($sqlPedido);
        $stmtPedido->bind_param("i", $id_pedido);
        $stmtPedido->execute();

        $resPedido = $stmtPedido->get_result();
        $pedido = $resPedido->fetch_assoc();

        if (!$pedido) {
            throw new Exception("Pedido no encontrado");
        }

        if ($pedido["id_repartidor"] !== null) {
            throw new Exception("Este pedido ya tiene repartidor asignado");
        }

        $id_estado_pedido = 5; // en camino

        $sqlActualizar = "UPDATE pedidos
                          SET id_repartidor = ?,
                              id_estado_pedido = ?
                          WHERE id_pedido = ?";

        $stmtActualizar = $this->conexion->prepare($sqlActualizar);
        $stmtActualizar->bind_param(
            "iii",
            $id_repartidor,
            $id_estado_pedido,
            $id_pedido
        );

        $stmtActualizar->execute();

        $comentario = "Pedido aceptado por el repartidor";

        $sqlHistorial = "INSERT INTO historial_pedido
            (id_pedido, id_estado_pedido, comentario)
            VALUES (?, ?, ?)";

        $stmtHistorial = $this->conexion->prepare($sqlHistorial);
        $stmtHistorial->bind_param(
            "iis",
            $id_pedido,
            $id_estado_pedido,
            $comentario
        );

        $stmtHistorial->execute();

        $this->conexion->commit();

        return [
            "id_pedido" => $id_pedido,
            "id_repartidor" => $id_repartidor,
            "estado" => "en camino"
        ];

    } catch (Exception $e) {
        $this->conexion->rollback();

        return [
            "error" => true,
            "message" => $e->getMessage()
        ];
    }
}

public function listarPorRepartidor($id_repartidor)
{
    $sql = "SELECT 
                p.id_pedido,
                r.nombre AS restaurante,
                ep.nombre AS estado,
                p.subtotal,
                p.costo_envio,
                p.descuento,
                p.total,
                p.metodo_pago,
                p.fecha_pedido
            FROM pedidos p
            INNER JOIN restaurantes r ON p.id_restaurante = r.id_restaurante
            INNER JOIN estados_pedido ep ON p.id_estado_pedido = ep.id_estado_pedido
            WHERE p.id_repartidor = ?
            ORDER BY p.fecha_pedido DESC";

    $stmt = $this->conexion->prepare($sql);
    $stmt->bind_param("i", $id_repartidor);
    $stmt->execute();

    $resultado = $stmt->get_result();

    $pedidos = [];

    while ($fila = $resultado->fetch_assoc()) {
        $pedidos[] = $fila;
    }

    return $pedidos;
}

public function cambiarEstadoRepartidor($id_pedido, $id_repartidor, $id_estado_pedido)
{
    $this->conexion->begin_transaction();

    try {
        $sqlPedido = "SELECT id_pedido 
                      FROM pedidos 
                      WHERE id_pedido = ?
                      AND id_repartidor = ?
                      LIMIT 1";

        $stmtPedido = $this->conexion->prepare($sqlPedido);
        $stmtPedido->bind_param("ii", $id_pedido, $id_repartidor);
        $stmtPedido->execute();

        $resPedido = $stmtPedido->get_result();

        if ($resPedido->num_rows === 0) {
            throw new Exception("Pedido no encontrado para este repartidor");
        }

        $sqlEstado = "SELECT nombre 
                      FROM estados_pedido 
                      WHERE id_estado_pedido = ?
                      LIMIT 1";

        $stmtEstado = $this->conexion->prepare($sqlEstado);
        $stmtEstado->bind_param("i", $id_estado_pedido);
        $stmtEstado->execute();

        $resEstado = $stmtEstado->get_result();
        $estado = $resEstado->fetch_assoc();

        if (!$estado) {
            throw new Exception("Estado no válido");
        }

        $sqlActualizar = "UPDATE pedidos
                          SET id_estado_pedido = ?
                          WHERE id_pedido = ?
                          AND id_repartidor = ?";

        $stmtActualizar = $this->conexion->prepare($sqlActualizar);
        $stmtActualizar->bind_param(
            "iii",
            $id_estado_pedido,
            $id_pedido,
            $id_repartidor
        );

        $stmtActualizar->execute();

        $comentario = "Estado actualizado por el repartidor a " . $estado["nombre"];

        $sqlHistorial = "INSERT INTO historial_pedido
            (id_pedido, id_estado_pedido, comentario)
            VALUES (?, ?, ?)";

        $stmtHistorial = $this->conexion->prepare($sqlHistorial);
        $stmtHistorial->bind_param(
            "iis",
            $id_pedido,
            $id_estado_pedido,
            $comentario
        );

        $stmtHistorial->execute();

        $this->conexion->commit();

        return [
            "id_pedido" => $id_pedido,
            "estado" => $estado["nombre"]
        ];

    } catch (Exception $e) {
        $this->conexion->rollback();

        return [
            "error" => true,
            "message" => $e->getMessage()
        ];
    }
}
    public function listarPorRestaurante($id_restaurante)
{
    $sql = "SELECT 
                p.id_pedido,
                p.id_cliente,
                p.id_restaurante,
                r.nombre AS restaurante,
                ep.nombre AS estado,
                p.subtotal,
                p.costo_envio,
                p.descuento,
                p.total,
                p.metodo_pago,
                p.observacion,
                p.fecha_pedido,
                u.nombre AS cliente_nombre,
                u.apellido AS cliente_apellido,
                u.telefono AS cliente_telefono
            FROM pedidos p
            INNER JOIN restaurantes r ON p.id_restaurante = r.id_restaurante
            INNER JOIN estados_pedido ep ON p.id_estado_pedido = ep.id_estado_pedido
            INNER JOIN clientes c ON p.id_cliente = c.id_cliente
            INNER JOIN usuarios u ON c.id_usuario = u.id_usuario
            WHERE p.id_restaurante = ?
            ORDER BY p.fecha_pedido DESC";

    $stmt = $this->conexion->prepare($sql);
    $stmt->bind_param("i", $id_restaurante);
    $stmt->execute();

    $resultado = $stmt->get_result();

    $pedidos = [];

    while ($fila = $resultado->fetch_assoc()) {
        $pedidos[] = $fila;
    }

    return $pedidos;
}

public function cambiarEstadoRestaurante($id_pedido, $id_restaurante, $id_estado_pedido)
{
    $this->conexion->begin_transaction();

    try {
        $estadosPermitidos = [2, 3, 4, 7];

        if (!in_array($id_estado_pedido, $estadosPermitidos)) {
            throw new Exception("Estado no permitido para restaurante");
        }

        $sqlPedido = "SELECT id_pedido 
                      FROM pedidos 
                      WHERE id_pedido = ?
                      AND id_restaurante = ?
                      LIMIT 1";

        $stmtPedido = $this->conexion->prepare($sqlPedido);
        $stmtPedido->bind_param("ii", $id_pedido, $id_restaurante);
        $stmtPedido->execute();

        $resPedido = $stmtPedido->get_result();

        if ($resPedido->num_rows === 0) {
            throw new Exception("Pedido no encontrado para este restaurante");
        }

        $sqlEstado = "SELECT nombre 
                      FROM estados_pedido 
                      WHERE id_estado_pedido = ?
                      LIMIT 1";

        $stmtEstado = $this->conexion->prepare($sqlEstado);
        $stmtEstado->bind_param("i", $id_estado_pedido);
        $stmtEstado->execute();

        $resEstado = $stmtEstado->get_result();
        $estado = $resEstado->fetch_assoc();

        if (!$estado) {
            throw new Exception("Estado no válido");
        }

        $sqlActualizar = "UPDATE pedidos
                          SET id_estado_pedido = ?
                          WHERE id_pedido = ?
                          AND id_restaurante = ?";

        $stmtActualizar = $this->conexion->prepare($sqlActualizar);
        $stmtActualizar->bind_param(
            "iii",
            $id_estado_pedido,
            $id_pedido,
            $id_restaurante
        );

        $stmtActualizar->execute();

        $comentario = "Estado actualizado por restaurante a " . $estado["nombre"];

        $sqlHistorial = "INSERT INTO historial_pedido
            (id_pedido, id_estado_pedido, comentario)
            VALUES (?, ?, ?)";

        $stmtHistorial = $this->conexion->prepare($sqlHistorial);
        $stmtHistorial->bind_param(
            "iis",
            $id_pedido,
            $id_estado_pedido,
            $comentario
        );

        $stmtHistorial->execute();

        $this->conexion->commit();

        return [
            "id_pedido" => $id_pedido,
            "id_restaurante" => $id_restaurante,
            "estado" => $estado["nombre"]
        ];

    } catch (Exception $e) {
        $this->conexion->rollback();

        return [
            "error" => true,
            "message" => $e->getMessage()
        ];
    }
}
    public function listarAdmin()
    {
        $sql = "SELECT p.id_pedido, p.id_cliente, p.id_restaurante, r.nombre AS restaurante, ep.nombre AS estado, p.total, p.metodo_pago, p.observacion, p.fecha_pedido, u.nombre AS cliente_nombre, u.apellido AS cliente_apellido, u.telefono AS cliente_telefono FROM pedidos p INNER JOIN restaurantes r ON p.id_restaurante = r.id_restaurante INNER JOIN estados_pedido ep ON p.id_estado_pedido = ep.id_estado_pedido INNER JOIN clientes c ON p.id_cliente = c.id_cliente INNER JOIN usuarios u ON c.id_usuario = u.id_usuario ORDER BY p.fecha_pedido DESC";
        $resultado = $this->conexion->query($sql);
        $pedidos = [];
        while ($fila = $resultado->fetch_assoc()) { $pedidos[] = $fila; }
        return $pedidos;
    }

    public function cambiarEstadoAdmin($id_pedido, $id_estado_pedido)
    {
        $this->conexion->begin_transaction();
        try {
            $sql = "UPDATE pedidos SET id_estado_pedido=? WHERE id_pedido=?";
            $stmt = $this->conexion->prepare($sql);
            $stmt->bind_param("ii", $id_estado_pedido, $id_pedido);
            $stmt->execute();

            $comentario = "Estado actualizado por administrador";
            $sqlHistorial = "INSERT INTO historial_pedido (id_pedido, id_estado_pedido, comentario) VALUES (?, ?, ?)";
            $stmtHistorial = $this->conexion->prepare($sqlHistorial);
            $stmtHistorial->bind_param("iis", $id_pedido, $id_estado_pedido, $comentario);
            $stmtHistorial->execute();

            $this->conexion->commit();
            return ["id_pedido" => $id_pedido, "id_estado_pedido" => $id_estado_pedido];
        } catch (Exception $e) {
            $this->conexion->rollback();
            return ["error" => true, "message" => $e->getMessage()];
        }
    }

}
