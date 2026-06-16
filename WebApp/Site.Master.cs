using Dominio;
using Dominio.Enums;
using System;
using System.Collections.Generic;
using System.IO;
using System.Web.UI.WebControls;

namespace WebApp
{
    public partial class Site : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["usuario"] == null)
            {
                Response.Redirect("~/Login.aspx");
                return;
            }

            Usuario u = (Usuario)Session["usuario"];
            bodyMain.Attributes["data-role"] = RolCss(u.Rol);

            if (!IsPostBack)
            {
                lblUsuario.Text = u.Nombre + " " + u.Apellido;
                lblInicialUsuario.Text = u.Nombre.Substring(0, 1).ToUpper();
                FiltrarMenuPorRol(u.Rol);
                MarcarSeccionActiva();
            }
        }

        private string RolCss(RolUsuario rol)
        {
            switch (rol)
            {
                case RolUsuario.Administrador: return "admin";
                case RolUsuario.Recepcionista: return "recepcionista";
                case RolUsuario.EncargadoCancha: return "encargado";
                default: return "cliente";
            }
        }

        private void FiltrarMenuPorRol(RolUsuario rol)
        {
            bool esAdmin = rol == RolUsuario.Administrador;
            bool esRecep = rol == RolUsuario.Recepcionista;
            bool esCliente = rol == RolUsuario.Cliente;

            lnkPanel.Visible = true;
            lnkReservas.Visible = true;

            lnkCalendario.Visible = !esCliente;

            lnkCanchas.Visible = !esCliente;
            lnkReservar.Visible = esCliente;

            lnkCupones.Visible = esAdmin || esRecep;
            lnkMisCupones.Visible = esCliente;

            lnkBeneficios.Visible = esAdmin || esCliente;
        }

        protected void btnCerrarSesion_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("~/Login.aspx");
        }

        // Resalta en el sidebar el link de la sección que se está viendo.
        private void MarcarSeccionActiva()
        {
            string pagina = Path.GetFileName(Request.AppRelativeCurrentExecutionFilePath);

            var links = new Dictionary<string, HyperLink>(StringComparer.OrdinalIgnoreCase)
            {
                { "Dashboard.aspx", lnkPanel },
                { "Canchas.aspx", lnkCanchas },
                { "CanchasCliente.aspx", lnkReservar },
                { "Reservas.aspx", lnkReservas },
                { "Cupones.aspx", lnkCupones },
                { "CuponesCliente.aspx", lnkMisCupones },
                { "Beneficios.aspx",     lnkBeneficios },
                { "Calendario.aspx", lnkCalendario },
            };

            HyperLink activo;
            if (links.TryGetValue(pagina, out activo) && activo != null)
            {
                activo.CssClass += " active";
            }
        }
    }
}
