using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using Dominio;
using Dominio.Enums;
using Negocio;

namespace WebApp
{
    public partial class Canchas : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Usuario u = Session["usuario"] as Usuario;
            if (u == null) { Response.Redirect("~/Login.aspx"); return; }
            if (u.Rol == RolUsuario.Cliente) { Response.Redirect("~/Dashboard.aspx"); return; }

            if (!IsPostBack)
            {
                CargarCanchas();
                CargarDeportes();
            }
        }

        private void CargarCanchas()
        {
            NegocioCanchas nCanchas = new NegocioCanchas();
            List<Cancha> canchas = nCanchas.ObtenerTodas();

            rptCanchas.DataSource = canchas;
            rptCanchas.DataBind();

            lblTotal.Text = canchas.Count + " canchas registradas";
        }

        protected void rptCanchas_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int idCancha = int.Parse(e.CommandArgument.ToString());

            if (e.CommandName == "Editar")
            {
                Cancha c = new NegocioCanchas().ObtenerPorId(idCancha);
                if (c == null) return;

                hfIdCancha.Value         = c.IdCancha.ToString();
                txtNombre.Text           = c.NombreFantasia;
                txtNumero.Text           = c.Numero.ToString();
                txtCapacidad.Text        = c.CapacidadJugadores.ToString();
                txtPrecio.Text           = c.Precio.ToString();
                txtSena.Text             = c.MontoSena.ToString();
                txtDescripcion.Text      = c.Descripcion;
                ddlDeporte.SelectedValue = c.Deporte.IdDeporte.ToString();

                lblTituloModalCancha.Text = "Editar cancha";
                AbrirModal("modalNuevaCancha", "Nueva cancha", "Editar cancha");
            }
            else if (e.CommandName == "Eliminar")
            {
                // No se elimina directo: se pide confirmación con un panel.
                Cancha c = new NegocioCanchas().ObtenerPorId(idCancha);
                hfBajaId.Value = idCancha.ToString();
                lblConfirmarBaja.Text = "¿Eliminar la cancha \"" + (c != null ? c.NombreFantasia : "") + "\"?";
                pnlConfirmarBaja.Visible = true;
            }
        }

        // Alta: limpia el formulario, deja todo en estado inicial y abre el modal.
        protected void btnNueva_Click(object sender, EventArgs e)
        {
            hfIdCancha.Value          = "";
            txtNombre.Text            = "";
            txtNumero.Text            = "";
            ddlDeporte.SelectedValue  = "0";
            txtCapacidad.Text         = "";
            txtPrecio.Text            = "";
            txtSena.Text              = "";
            txtDescripcion.Text       = "";
            lblErrorCancha.Visible    = false;
            lblTituloModalCancha.Text = "Nueva cancha";

            AbrirModal("modalNuevaCancha", "Nueva cancha", "Editar cancha");
        }

        // Confirma la eliminación: da de baja el id guardado y oculta el panel.
        protected void btnConfirmarBaja_Click(object sender, EventArgs e)
        {
            new NegocioCanchas().BajaLogica(int.Parse(hfBajaId.Value));
            pnlConfirmarBaja.Visible = false;
            CargarCanchas();
        }

        protected void btnCancelarBaja_Click(object sender, EventArgs e)
        {
            pnlConfirmarBaja.Visible = false;
        }

        private void CargarDeportes()
        {
            NegocioCanchas nCanchas = new NegocioCanchas();

            ddlDeporte.DataSource = nCanchas.ObtenerDeportes();
            ddlDeporte.DataTextField = "Nombre";
            ddlDeporte.DataValueField = "IdDeporte";
            ddlDeporte.DataBind();
            ddlDeporte.Items.Insert(0, new ListItem("-- Seleccioná un deporte --", "0"));
        }

        protected string GetDeporteEmoji(object nombreObj)
        {
            string nombre = (nombreObj ?? "").ToString().ToLower();
            if (nombre.Contains("fútbol") || nombre.Contains("futbol")) return "⚽";
            if (nombre.Contains("tenis")) return "🎾";
            if (nombre.Contains("básquet") || nombre.Contains("basquet")) return "🏀";
            if (nombre.Contains("pádel") || nombre.Contains("padel")) return "🏓";
            if (nombre.Contains("vóley") || nombre.Contains("voley")) return "🏐";
            return "🏟️";
        }

        protected string FormatearPrecio(object precioObj)
        {
            return "$" + precioObj + " /hora";
        }

        protected string GetDeporteAccent(object nombreObj)
        {
            string nombre = (nombreObj ?? "").ToString().ToLower();
            if (nombre.Contains("fútbol") || nombre.Contains("futbol")) return "#2d6a4f";
            if (nombre.Contains("tenis")) return "#b5870a";
            if (nombre.Contains("básquet") || nombre.Contains("basquet")) return "#9b4d96";
            if (nombre.Contains("pádel") || nombre.Contains("padel")) return "#1a6fa8";
            if (nombre.Contains("vóley") || nombre.Contains("voley")) return "#c0392b";
            return "#4a5568";
        }

        protected void btnGuardarCancha_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            Cancha cancha = new Cancha
            {
                NombreFantasia     = txtNombre.Text.Trim(),
                Numero             = int.Parse(txtNumero.Text),
                Deporte            = new Deporte { IdDeporte = int.Parse(ddlDeporte.SelectedValue) },
                CapacidadJugadores = int.Parse(txtCapacidad.Text),
                Precio             = decimal.Parse(txtPrecio.Text),
                MontoSena          = decimal.Parse(txtSena.Text),
                Descripcion        = txtDescripcion.Text.Trim(),
                Activa             = true
            };

            NegocioCanchas nCanchas = new NegocioCanchas();
            if (string.IsNullOrEmpty(hfIdCancha.Value))
            {
                nCanchas.Agregar(cancha);
            }
            else
            {
                cancha.IdCancha = int.Parse(hfIdCancha.Value);
                nCanchas.Modificar(cancha);
            }

            Response.Redirect("Canchas.aspx");
        }

        private void AbrirModal(string modalId, string tituloNuevo, string tituloEditar)
        {
            bool esEdicion = !string.IsNullOrEmpty(hfIdCancha.Value);
            string titulo = esEdicion ? tituloEditar : tituloNuevo;
            string script =
                "bootstrap.Modal.getOrCreateInstance(document.getElementById('" + modalId + "')).show();";
            ClientScript.RegisterStartupScript(GetType(), "abrirModal", script, true);
        }
    }
}
