using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using Dominio;
using Dominio.Enums;
using Negocio;

namespace WebApp
{
    public partial class CuponesCliente : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // El Page_Load de la página corre ANTES que el del Site.Master, así que
            // su redirect no nos cubre: el guard de sesión va acá mismo.
            // HACER: control de acceso por rol — pendiente cambio de roles (guard centralizado futuro)
            if (Session["usuario"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (!IsPostBack)
                CargarCupones();
        }

        private void CargarCupones()
        {
            Usuario usuario = (Usuario)Session["usuario"];
            List<Cupon> cupones = new NegocioCupones().ObtenerPorUsuario(usuario.IdUsuario);

            // Usables ahora vs historial (canjeados / vencidos / agotados)
            List<Cupon> disponibles = cupones.Where(c => c.Estado == EstadoCupon.Activo).ToList();
            List<Cupon> historial = cupones.Where(c => c.Estado != EstadoCupon.Activo).ToList();

            rptDisponibles.DataSource = disponibles;
            rptDisponibles.DataBind();
            rptHistorial.DataSource = historial;
            rptHistorial.DataBind();

            pnlVacio.Visible = cupones.Count == 0;
            pnlDisponibles.Visible = cupones.Count > 0;
            pnlSinDisponibles.Visible = cupones.Count > 0 && disponibles.Count == 0;
            pnlHistorial.Visible = historial.Count > 0;

            lblTotal.Text = disponibles.Count == 1
                ? "1 cupón disponible"
                : disponibles.Count + " cupones disponibles";
        }

        // ── Helpers de presentación (reutilizados de Cupones.aspx.cs) ──────────

        protected string GetBadgeSymbol(object tipoDescuentoObj)
        {
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            return tipo == TipoDescuento.Porcentaje ? "%" : "$";
        }

        protected string GetBadgeClass(object tipoDescuentoObj)
        {
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            return tipo == TipoDescuento.MontoFijo ? "monto-fijo" : "";
        }

        protected string GetTipoNombre(object tipoDescuentoObj)
        {
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            return tipo == TipoDescuento.ReservaGratis ? "Reserva gratis" : "Descuento en reserva";
        }

        protected string GetEstadoBadgeClass(object estadoObj)
        {
            EstadoCupon estado = (EstadoCupon)estadoObj;
            switch (estado)
            {
                case EstadoCupon.Activo: return "text-success bg-success-subtle";
                case EstadoCupon.Canjeado: return "text-secondary bg-secondary-subtle";
                case EstadoCupon.Vencido: return "text-warning bg-warning-subtle";
                case EstadoCupon.Agotado: return "text-danger bg-danger-subtle";
                default: return "text-secondary bg-secondary-subtle";
            }
        }

        protected string FormatearValor(object tipoDescuentoObj, object valorObj)
        {
            if (valorObj == null || valorObj == DBNull.Value) return "-";
            decimal valor = Convert.ToDecimal(valorObj);
            TipoDescuento tipo = (TipoDescuento)tipoDescuentoObj;
            if (tipo == TipoDescuento.Porcentaje)
                return valor == 100 ? "100% OFF" : $"{valor:0}% OFF";
            return $"${valor:0} OFF";
        }

        protected string FormatearMeta(string tipo, object val1, object val2 = null)
        {
            switch (tipo)
            {
                case "fecha":
                    if (val1 == null || val1 == DBNull.Value) return "Sin vencimiento";
                    return "Válido hasta: " + Convert.ToDateTime(val1).ToString("yyyy-MM-dd");
                case "usos":
                    string limite = (val2 == null || val2 == DBNull.Value) ? "∞" : val2.ToString();
                    return "Usado: " + val1 + "/" + limite + " veces";
                default:
                    return "";
            }
        }
    }
}
