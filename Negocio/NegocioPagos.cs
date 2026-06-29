using System;
using System.Collections.Generic;
using Dominio;
using Dominio.Enums;

namespace Negocio
{
    public class NegocioPagos
    {
        // Registra un pago sobre una reserva. No toca el estado de pago de la
        // reserva: de eso se encarga el trigger TR_SincronizarEstadoPago, que
        // recalcula Señado/Pagado a partir de la suma de pagos al insertar acá.
        public void RegistrarPago(Pago pago, int idReserva)
        {
            // Defensa en profundidad: el total pagado no puede superar el precio de
            // la reserva. La base también lo valida (TR_ValidarMontoPago), pero acá
            // cortamos antes con un mensaje claro del saldo restante.
            decimal precio = ObtenerPrecioTotal(idReserva);
            decimal pagado = ObtenerTotalPagado(idReserva);
            decimal saldo  = precio - pagado;
            if (pago.Monto > saldo)
                throw new Exception(string.Format(
                    "El pago supera el saldo pendiente de la reserva (saldo: {0:C0}).", saldo));

            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    INSERT INTO Pagos (Monto, IDReserva, IDFormaPago)
                    VALUES (@monto, @idReserva, @idFormaPago)");
                datos.AgregarParametro("@monto", pago.Monto);
                datos.AgregarParametro("@idReserva", idReserva);
                datos.AgregarParametro("@idFormaPago", (int)pago.FormaDePago);
                datos.EjecutarAccion();
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Precio total de una reserva. Lo usa el guard de RegistrarPago para
        // validar que el pago no supere el saldo pendiente.
        private decimal ObtenerPrecioTotal(int idReserva)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta("SELECT PrecioTotal FROM Reservas WHERE IDReserva = @idReserva");
                datos.AgregarParametro("@idReserva", idReserva);
                datos.EjecutarLectura();
                if (datos.Lector.Read())
                    return (decimal)datos.Lector["PrecioTotal"];
                return 0m;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Cuánto se pagó hasta ahora de una reserva. Sirve para mostrar el saldo
        // pendiente en el modal antes de registrar un pago nuevo.
        public decimal ObtenerTotalPagado(int idReserva)
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    SELECT ISNULL(SUM(Monto), 0) AS Total
                    FROM Pagos
                    WHERE IDReserva = @idReserva");
                datos.AgregarParametro("@idReserva", idReserva);
                datos.EjecutarLectura();

                if (datos.Lector.Read())
                    return (decimal)datos.Lector["Total"];

                return 0m;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Total cobrado en el día de hoy. Suma de los pagos cuya Fecha cae hoy.
        // Es plata real que entró, no precio teorico de los turnos. Alimenta el KPI
        // "Ingresos del día" del Panel.
        public decimal ObtenerIngresosDelDia()
        {
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    SELECT ISNULL(SUM(Monto), 0) AS Total
                    FROM   Pagos
                    WHERE  CAST(FechaHora AS DATE) = CAST(GETDATE() AS DATE)");
                datos.EjecutarLectura();

                if (datos.Lector.Read())
                    return (decimal)datos.Lector["Total"];

                return 0m;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }

        // Lista los pagos individuales de una reserva (cada seña / saldo cargado),
        // ordenados por fecha. Alimenta el modal de detalle de pago.
        public List<Pago> ObtenerPagosPorReserva(int idReserva)
        {
            List<Pago> lista = new List<Pago>();
            AccesoDatos datos = new AccesoDatos();
            try
            {
                datos.SetearConsulta(@"
                    SELECT IDPago, Monto, FechaHora, IDFormaPago
                    FROM   Pagos
                    WHERE  IDReserva = @idReserva
                    ORDER BY FechaHora");
                datos.AgregarParametro("@idReserva", idReserva);
                datos.EjecutarLectura();

                while (datos.Lector.Read())
                {
                    lista.Add(new Pago
                    {
                        IdPago      = (int)datos.Lector["IDPago"],
                        Monto       = (decimal)datos.Lector["Monto"],
                        FechaHora   = (DateTime)datos.Lector["FechaHora"],
                        FormaDePago = (FormaPago)(int)datos.Lector["IDFormaPago"]
                    });
                }
                return lista;
            }
            finally
            {
                datos.CerrarConexion();
            }
        }
    }
}
