<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PDCMainFilter.ascx.cs" Inherits="PDC.UserControls.PDCMainFilter" %>


 <asp:Panel ID="p_filter" runat="server" CssClass="PDCMainFilter" Visible="False">
    
    <a name="p_QueryMonitor_WAR_SessionsPortlet_INSTANCE_oIZ3"></a>
    <div class="portlet-container-small chromehover ">
        <!-- begin header bar -->
        <div class="portlet-header-bar-filter">
            <div class="portlet-chrome-header">
                <div class="portlet-chrome-gradient">
                    <div class="portlet-chrome-TL">
                        &#160;
                    </div>
                    <div class="portlet-chrome-top">
                        &#160;
                    </div>
                    <div class="portlet-chrome-TR">
                        &#160;
                    </div>
                </div>
                <div class="portlet-wrap-title">
                    <span class="portlet-title">Filter</span>
                </div>
                <div class="rightMe">
                    <asp:LinkButton ID="BFilterCloseImage" runat="server"  CommandName="DiscardAndClose" CommandArgument="true" OnCommand="BFilterPressed" CssClass="layout-tab-close" ToolTip="Discard & Close">&#160;</asp:LinkButton>
                </div>
            </div>
            <!-- end portlet-chrome-header -->
        </div>
        <!-- end tdpagetop -->
    </div>
    <!-- end tdpagetabregion -->
    <!-- end portlet-header-bar -->
    <div class="portlet-box">
        <div class="portlet-minimum-height">
            <div class="PortletBoxInnerFilter" align="center">
                <p>
                    <span class="ModuleHeader">Current Filter Applied?</span>
                </p>
                <table class="PDCStatTableFilter" border="0" cellspacing="1" cellpadding="2">
                    <thead class="PDCStatTableFilter">
                        <tr><th>Filter</th><th>Value</th><th>%<u>value</u>%</th></tr>
                    </thead>
                    <tbody>
                        <tr>
	                        <td class="PDCStatTableFilter">Job Name</td>
	                        <td class="PDCStatTableFilterValue"><asp:TextBox ID="TFilterJobName" runat="server" Text=""></asp:TextBox></td>
	                        <td class="PDCStatTableFilterValueWC"><asp:CheckBox ID="TFilterJobNameWC" runat="server" Text="" ToolTip="Discard & Close" CssClass="PDCStatTableFilterValueWC" Checked="true" /></td>
                        </tr>
                        <tr>
	                        <td class="PDCStatTableFilter">Stream Name</td>
	                        <td class="PDCStatTableFilterValue"><asp:TextBox ID="TFilterStreamName" runat="server" Text=""></asp:TextBox></td>
	                        <td class="PDCStatTableFilterValueWC"><asp:CheckBox ID="TFilterStreamNameWC" runat="server" Text="" ToolTip="Discard & Close" CssClass="PDCStatTableFilterValueWC" Checked="true" /></td>
                        </tr>
                        <tr>
	                        <td class="PDCStatTableFilter">Table Name</td>
	                        <td class="PDCStatTableFilterValue"><asp:TextBox ID="TFilterTableName" runat="server" Text=""></asp:TextBox></td>
	                        <td class="PDCStatTableFilterValueWC"><asp:CheckBox ID="TFilterTableNameWC" runat="server" Text="" ToolTip="Discard & Close"  CssClass="PDCStatTableFilterValueWC" Checked="true" /></td>
                        </tr>
                        <tr>
	                        <td class="PDCStatTableFilter">Job Type</td>
	                        <td class="PDCStatTableFilterValue"><asp:TextBox ID="TFilterJobType" runat="server" Text=""></asp:TextBox></td>
	                        <td class="PDCStatTableFilterValueWC"><asp:CheckBox ID="TFilterJobTypeWC" runat="server" Text="" ToolTip="Discard & Close"  CssClass="PDCStatTableFilterValueWC" Checked="true" /></td>
                        </tr>
                        <tr>
	                        <td class="PDCStatTableFilter">Job Category</td>
	                        <td class="PDCStatTableFilterValue"><asp:TextBox ID="TFilterJobCategory" runat="server" Text=""></asp:TextBox></td>
	                        <td class="PDCStatTableFilterValueWC"><asp:CheckBox ID="TFilterJobCategoryWC" runat="server" Text="" ToolTip="Discard & Close" CssClass="PDCStatTableFilterValueWC" Checked="true" /></td>
                        </tr>
                        <tr>
	                        <td class="PDCStatTableFilter">Phase</td>
	                        <td class="PDCStatTableFilterValue"><asp:TextBox ID="TFilterPhase" runat="server" Text="" ToolTip="Discard & Close"></asp:TextBox></td>
	                        <td class="PDCStatTableFilterValueWC"><asp:CheckBox ID="TFilterPhaseWC" runat="server" Text="" ToolTip="Discard & Close" CssClass="PDCStatTableFilterValueWC" Checked="true" /></td>
                        </tr>
                    </tbody>
                </table>
                <div class="PDCFilterButtons">
                            <asp:LinkButton ID="BFilterApply" runat="server"  CommandName="Apply" CommandArgument="true" OnCommand="BFilterPressed" CssClass="PDCButtonWhite"><span>Apply</span></asp:LinkButton>
                            <asp:LinkButton ID="BFilterReset" runat="server"  CommandName="Reset" CommandArgument="true" OnCommand="BFilterPressed" CssClass="PDCButtonWhite"><span>Reset</span></asp:LinkButton>
                            <asp:LinkButton ID="BFilterClose" runat="server"  CommandName="Close" CommandArgument="true" OnCommand="BFilterPressed" CssClass="PDCButtonWhite"><span>Apply & Close</span></asp:LinkButton>
                            <asp:LinkButton ID="BFilterDiscard" runat="server"  CommandName="DiscardAndClose" CommandArgument="true" OnCommand="BFilterPressed" CssClass="PDCButtonWhite"><span>Discard & Close</span></asp:LinkButton>
                        </div>
            </div>
        </div>
    </div>
    <!-- end portlet-box -->
    <div class="portlet-footer-bar">
        <div class="portlet-chrome-footer">
            <div class="portlet-chrome-gradient">
                <div class="portlet-chrome-BL">
                    &#160;
                </div>
                <div class="portlet-chrome-bottom">
                    &#160;
                </div>
                <div class="portlet-chrome-BR">
                    &#160;
                </div>
            </div>
        </div>
        <!-- end portlet-chrome-footer -->
    </div>
    <!-- end portlet-footer-bar -->
</asp:Panel>